require 'json'
require 'savon'


def check_project_and_stream_exist(client, project_name, stream_name)
	# Check if the project exists first
	response = client.call(:get_projects)
	projects = response.body[:get_projects_response][:return]
	target_project = nil
	for project in projects
		if project[:id][:name] == project_name
			puts "Project #{project_name} exists"
			target_project = project
		end
	end
	# If the project doesn't exist
	if target_project == nil
		puts "Project #{project_name} does not exist"
		create_project(client, project_name)
		create_stream(client, project_name, stream_name)
	else
		stream_exists = check_stream_exists(client, target_project, stream_name)
		if not stream_exists
			create_stream(client, project_name, stream_name)
		end
	end
end

def check_stream_exists(client, project_data, stream_name)
	streams = project_data[:streams]
	# If the project has only one stream, reformat the data
	if project_data[:streams].class == Hash
		streams = [streams]
	# If it has no streams
	elsif project_data[:streams] == nil
		return false
	end
	for stream in streams
		if stream[:id][:name] == stream_name
			puts "Stream #{stream_name} exists"
			return true
		end
	end
	puts "Stream #{stream_name} does not exist"
	return false
end

def create_project(client, project_name)
	puts "Creating project #{project_name}"
	response = client.call(
		:create_project, 
		message: { 
			projectSpec: {
				name: project_name
			}
		}
	)
end

def create_stream(client, project_name, stream_name)
	puts "Creating stream #{stream_name}"
	response = client.call(
		:create_stream_in_project, 
		message: { 
			projectId: {
				name: project_name
			},
			streamSpec: {
				name: stream_name,
				triageStoreId: {
					name: "Default Triage Store"
				}
			}
		}
	)
end

def main()
	# Check environment variables
	variables = %w{CONNECT_AUTH_KEY COVERITY_PROJECT_NAME COVERITY_STREAM_NAME}
	missing = variables.find_all { |v| ENV[v] == nil }
	unless missing.empty?
		STDERR.puts("\tError: Missing environment variables: #{missing.join(', ')}.")
		exit(1)
	end

	# Validate project and stream names
	project_name = ENV['COVERITY_PROJECT_NAME']
	stream_name = ENV['COVERITY_STREAM_NAME']
	# Names cannot contain any of /\*`'":
	invalid_chars = '/\*`\'":'
	invalid_chars.each_char{ |c|
		if project_name.include?(c) or stream_name.include?(c)
			STDERR.puts("\tError: Project and stream names cannot contain the characters /\\*`'\":")
			exit(1)
		end
	}

	# Parse connection data from CONNECT_AUTH_KEY
	auth_data 		= JSON.parse(ENV['CONNECT_AUTH_KEY'])
	hostname		= auth_data["comments"]["host"]
	auth_user		= auth_data["username"]
	auth_key 		= auth_data["key"]

	# Configure the Coverity SOAP client
	client = Savon.client(
		wsdl: "https://#{hostname}/ws/v9/configurationservice?wsdl",
		wsse_auth: [auth_user, auth_key],
		follow_redirects: true,
	)

	check_project_and_stream_exist(client, project_name, stream_name)
end

main()