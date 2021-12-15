#!/bin/bash

# Input environment variables:
: "${component:?Need to set component}"
: "${stage:?Need to set stage}"
: "${scanner_image:?Need to set scanner_image}"
: "${blackduck_access_token:?Need to set blackduck_access_token}"

echo
echo "Parsing components.yaml for Black Duck scan configuration"
echo 

# Check that the blackduck config exists and is formatted correctly
projects=$(yq r ./components.yaml ${component}.scan_blackduck)
num_projects=$(yq r ./components.yaml ${component}.scan_blackduck | grep '^-.*$' | wc -l)
if [[ "$projects" == "null" ]] || [[ $num_projects -eq 0 ]]; then
	echo "		Warning: ${component}.scan_blackduck is missing from '${component}' components.yaml or not set up correctly"
	echo "		Skipping scan for this component"
	exit 0
fi

# echo "############# DEBUG ############"

# echo "Create a large file to simulate a big repo"
# truncate -s 5G largefile.txt

# echo "########## END DEBUG ###########"

echo "Creating volume for persistent data"
docker container create --name dummy -v persistentdata:/root/project hello-world
echo "Copying repository into volume"
docker cp . dummy:/root/project
docker rm dummy

for project_idx in $(seq 0 $(( num_projects - 1)) ); do
	project=$(yq r ./components.yaml "${component}.scan_blackduck[${project_idx}].project")
	# You can use '#{component}' in the scan_version_name key to insert the version dynamically
	project=$(echo "${project}" | sed "s@#{component}@${component}@g")
	scan_version_name=""
	# If stage-to-scan mappings are defined, check for a match
	if [[ "$(yq r ./components.yaml "${component}.scan_blackduck[${project_idx}].stages")" != "null" ]]; then
		num_stages=$(yq r ./components.yaml "${component}.scan_blackduck[${project_idx}].stages.*.name" | wc -l)
		for stage_idx in $(seq 0 $(( num_stages - 1)) ); do
			# See if branch matches and it is enabled
			prefix=$(yq r ./components.yaml "${component}.scan_blackduck[${project_idx}].stages.[${stage_idx}].name")
			enabled=$(yq r ./components.yaml "${component}.scan_blackduck[${project_idx}].stages.[${stage_idx}].enabled")
			# A missing 'enabled' key will also count as 'enabled'
			if [[ "$enabled" == "null" ]]; then
				enabled="true"
			fi
			if [[ "${stage}" =~ ^"$prefix" ]] && [[ "$enabled" == "true" ]]; then
				echo "Branch name matches prefix $prefix"
				scan_version_name=$(yq r ./components.yaml "${component}.scan_blackduck[${project_idx}].stages.[${stage_idx}].scan_version_name")
				break
			fi
		done

		if [[ "$scan_version_name" == "null" ]] || [[ "$scan_version_name" == "" ]]; then
			echo "Warning: Could not find an enabled \"${component}.scan_blackduck[${project_idx}].stages\" entry in components.yaml"
			echo "		that matches the stage '${stage}'. This is required to map a scan to a Black Duck 'version'"
			echo "		Skipping scan for this project"
			echo
			continue
		fi
	else
		# Otherwise, use [component].scan_blackduck[#].scan_version_name instead
		scan_version_name=$(yq r ./components.yaml "${component}.scan_blackduck[${project_idx}].scan_version_name")
		if [[ "$scan_version_name" == "null" ]]; then
			echo "	Error: Must provide stage-to-scan mappings or ${component}.scan_blackduck[${project_idx}].scan_version_name"
		fi
	fi

	# You can use '#{version}' in the scan_version_name key to insert the version dynamically
	major_version=$(yq r ./components.yaml ${component}.major_version)
	minor_version=$(yq r ./components.yaml ${component}.minor_version)
	patch_version=$(yq r ./components.yaml ${component}.patch_version)
	version_prefix="${major_version}.${minor_version}.${patch_version}"
	scan_version_name=$(echo "${scan_version_name}" | sed "s@#{version}@${version_prefix}@g")

	# Get list of scan paths and arrange them into a comma-separated list
	scan_paths_yaml=$(yq r ./components.yaml "${component}.scan_blackduck[${project_idx}].scan_paths")
	scan_paths=""
	if [[ "$scan_paths_yaml" != "null" ]]; then
		for i in $(echo "$scan_paths_yaml" | cut -d' ' -f2-); do
			scan_paths+="${i},"
		done
		scan_paths=$(echo ${scan_paths} | sed 's/,$//')
	else
		# If scan_paths key is not provided, default to the app_dir key for the component
		scan_paths=$(yq r ./components.yaml "${component}.app_dir")
		if [[ "$scan_paths" == "null" ]]; then
			echo "	Error: Must provide ${component}.app_dir key or ${component}.scan_blackduck[${project_idx}].scan_paths"
			exit
		fi
	fi

	additional_arguments=$(yq r ./components.yaml "${component}.scan_blackduck[${project_idx}].additional_arguments")
	if [[ "$additional_arguments" == "null" ]]; then
		additional_arguments=""
	fi

	custom_build=$(yq r ./components.yaml ${component}.scan_blackduck[${project_idx}].custom_build)
	if [[ "$custom_build" == "null" ]]; then
		custom_build=""
	fi

	# Create a Black Duck project for this project name if one doesn't exist
	echo "Checking for existing BD project '${project}'"
	BLACKDUCK_ACCESS_TOKEN=${blackduck_access_token} \
	BLACKDUCK_PROJECT_NAME=${project} \
	BLACKDUCK_VERSION_NAME=${scan_version_name} \
	ruby .circleci/helpers/blackduck-create-project.rb

	echo
	echo "Running sub-container"

	docker run \
	-v persistentdata:/root/project \
	--env ADDITIONAL_SCAN_ARGUMENTS="${additional_arguments}" \
	--env AUTOMATION_USER_TOKEN="${blackduck_access_token}" \
	--env CUSTOM_BUILD="${custom_build}" \
	--env DEBUG="${DEBUG}" \
	--env PATHS="${scan_paths}" \
	--env PROJECT="${project}" \
	--env VERSION="${scan_version_name}" \
	${scanner_image}

done