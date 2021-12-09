#!/bin/bash

# Input environment variables:
: "${component:?Need to set component}"
: "${version:?Need to set version}"
: "${stage:?Need to set stage}"
: "${scanner_image:?Need to set scanner_image}"
: "${CONNECT_AUTH_KEY:?Need to set CONNECT_AUTH_KEY}"
: "${CONNECT_HOST:?Need to set CONNECT_HOST}"
: "${CONNECT_DATAPORT:?Need to set CONNECT_DATAPORT}"

# Install a gem for later use by coverity-create-project.rb
gem install savon -v 2.12.1

echo
echo "Parsing components.yaml for Coverity scan configuration"
echo 

# Check that the coverity config exists and is formatted correctly
projects=$(yq r ./components.yaml ${component}.scan_coverity)
num_projects=$(yq r ./components.yaml ${component}.scan_coverity | grep '^-.*$' | wc -l)
if [[ "$projects" == "null" ]] || [[ $num_projects -eq 0 ]]; then
	echo "		Warning: ${component}.scan_coverity is missing from '${component}' components.yaml or not set up correctly"
	echo "		Skipping scan for this component"
	exit 0
fi

# Copy repo into a volume

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
	project_name=$(yq r ./components.yaml "${component}.scan_coverity[${project_idx}].project")
	echo "###########"
	echo "Coverity Scan - Project: ${project_name}"
	echo "###########"

	stream_name=""
	# If stage-to-stream mappings are defined, check for a match
	if [[ "$(yq r ./components.yaml "${component}.scan_coverity[${project_idx}].stages")" != "null" ]]; then
		num_stages=$(yq r ./components.yaml "${component}.scan_coverity[${project_idx}].stages.*.name" | wc -l)
		for stage_idx in $(seq 0 $(( num_stages - 1)) ); do
			# See if branch matches and it is enabled
			prefix=$(yq r ./components.yaml "${component}.scan_coverity[${project_idx}].stages.[${stage_idx}].name")
			enabled=$(yq r ./components.yaml "${component}.scan_coverity[${project_idx}].stages.[${stage_idx}].enabled")
			# A missing 'enabled' key will also count as 'enabled'
			if [[ "$enabled" == "null" ]]; then
				enabled="true"
			fi
			if [[ "${stage}" =~ ^"$prefix" ]] && [[ "$enabled" == "true" ]]; then
				echo "Branch name matches prefix $prefix"
				stream_name=$(yq r ./components.yaml "${component}.scan_coverity[${project_idx}].stages.[${stage_idx}].stream_name")
				break
			fi
		done

		if [[ "$stream_name" == "null" ]] || [[ "$stream_name" == "" ]]; then
			echo "Warning: Could not find an enabled \"${component}.scan_coverity[${project_idx}].stages\" entry in components.yaml"
			echo "		that matches the stage '${stage}'. This is required to map a scan to a Coverity 'stream'"
			echo "		Skipping scan for this project"
			echo
			continue
		fi
	else
		# Otherwise, use [component].scan_coverity[#].stream_name instead
		stream_name=$(yq r ./components.yaml "${component}.scan_coverity[${project_idx}].stream_name")
		if [[ "$stream_name" == "null" ]]; then
			echo "	Error: Must provide stage-to-stream mappings or ${component}.scan_coverity[${project_idx}].stream_name"
		fi
	fi

	# Replace '#{component}' with the component name
	project_name=$(echo "$project_name" | sed "s/#{component}/${component}/g")

	# Replace '#{project}' with the project name
	stream_name=$(echo "$stream_name" | sed "s/#{project}/${project_name}/g")
	# Replace '#{component}' with the component name
	stream_name=$(echo "$stream_name" | sed "s/#{component}/${component}/g")

	# Create a Coverity project and stream if they don't exist
	echo "Checking for existing Coverity project and stream"
	CONNECT_AUTH_KEY=${CONNECT_AUTH_KEY} \
	COVERITY_PROJECT_NAME=${project_name} \
	COVERITY_STREAM_NAME=${stream_name} \
	ruby .circleci/helpers/coverity-create-project.rb

	echo "Running sub-container"

	docker run \
	-v persistentdata:/root/project \
	--env CUSTOM_BUILD="$(yq r ./components.yaml "${component}.scan_coverity[${project_idx}].custom_build")" \
	--env CONFIGURE_ARGS="$(yq r ./components.yaml "${component}.scan_coverity[${project_idx}].cov_configure")" \
	--env BUILD_ARGS="$(yq r ./components.yaml "${component}.scan_coverity[${project_idx}].cov_build")" \
	--env CAPTURE_ARGS="$(yq r ./components.yaml "${component}.scan_coverity[${project_idx}].cov_capture")" \
	--env ANALYZE_ARGS="$(yq r ./components.yaml "${component}.scan_coverity[${project_idx}].cov_analyze")" \
	--env MANAGE_EMIT_ARGS="$(yq r ./components.yaml "${component}.scan_coverity[${project_idx}].cov_manage_emit")" \
	--env CONNECT_AUTH_KEY="${CONNECT_AUTH_KEY}" \
	--env CONNECT_STREAM="${stream_name}" \
	--env CONNECT_HOST="${CONNECT_HOST}" \
	--env CONNECT_DATAPORT="${CONNECT_DATAPORT}" \
	--env BUILD_VERSION="${version}" \
	--env DEBUG="${DEBUG}" \
	${scanner_image}

done
