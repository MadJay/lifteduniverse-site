require 'net/http'
require 'net/https'
require 'uri'
require 'json'

class BlackDuckApiError < StandardError; end

def get_bearer_token(api_token, root)
	uri = URI.parse(root + "api/tokens/authenticate")
	# These headers are required for Black Duck to return correct response text
	header = {
		'Content-Type'	=> 'application/json',
		'Accept'		=> 'application/vnd.blackducksoftware.user-4+json',
		'Authorization'	=> "token #{api_token}"
	}

	# Create the HTTP objects
	https = Net::HTTP.new(uri.host, uri.port)
	https.use_ssl = true
	request = Net::HTTP::Post.new(uri.request_uri, header)

	# Send the request
	response = https.request(request)
	raise BlackDuckApiError, response.body unless response.code == "200"
	# Get bearer token from JSON
	body = JSON.parse(response.body)
	bearer_token = body["bearerToken"]
	return bearer_token
end

def check_project_exists(bearer_token, root, project_name)
	# Set the request to search the project by name
	uri = URI.parse(root + "api/projects" + "?q=name:#{project_name}")
	# These headers are required for Black Duck to return correct response text
	header = {
		'Content-Type'	=> 'application/json',
		'Accept'		=> 'application/vnd.blackducksoftware.project-detail-4+json',
		'Authorization'	=> "Bearer #{bearer_token}"
	}

	# Create the HTTP objects
	https = Net::HTTP.new(uri.host, uri.port)
	https.use_ssl = true
	request = Net::HTTP::Get.new(uri.request_uri, header)

	# Send the request
	response = https.request(request)
	raise BlackDuckApiError, response.body unless response.code == "200"
	body = JSON.parse(response.body)
	# If the search matches an existing project
	if (body["totalCount"] == 1)
		puts "Blackduck project #{project_name} exists"
		return true
	else
		puts "Blackduck project #{project_name} does not exist"
		return false
	end
end

def create_project(bearer_token, root, project_name, version_name)
	uri = URI.parse(root + "/api/projects")
	# These headers are required for Black Duck to return correct response text
	header = {
		'Content-Type'	=> 'application/vnd.blackducksoftware.project-detail-4+json',
		'Accept'		=> 'application/vnd.blackducksoftware.project-detail-4+json',
		'Authorization'	=> "Bearer #{bearer_token}"
	}

	# Required keys:
	# Name, description, projectLevelAdjustments
	body = { 
		'name' => project_name,
		'description' => "Project created by CircleCI",
		'projectLevelAdjustments' => true,
		'versionRequest' => {
			'versionName' => version_name,
			'phase' => "DEVELOPMENT",
			'distribution' => "EXTERNAL"
		}
	}

	# Create the HTTP objects
	https = Net::HTTP.new(uri.host, uri.port)
	https.use_ssl = true
	request = Net::HTTP::Post.new(uri.request_uri, header)
	request.body = body.to_json
	# Send the request
	response = https.request(request)
	raise BlackDuckApiError, response.body unless response.code == "201"
end

def main()
	# Check environment variables
	variables = %w{BLACKDUCK_ACCESS_TOKEN BLACKDUCK_PROJECT_NAME BLACKDUCK_VERSION_NAME}
	missing = variables.find_all { |v| ENV[v] == nil }
	unless missing.empty?
		STDERR.puts("\tError: Missing environment variables: #{missing.join(', ')}.")
		exit(1)
	end
	api_token 		= ENV['BLACKDUCK_ACCESS_TOKEN']
	project_name 	= ENV['BLACKDUCK_PROJECT_NAME']
	version_name 	= ENV['BLACKDUCK_VERSION_NAME']

	root = "https://wowza.app.blackduck.com/"

	begin
		bearer_token = get_bearer_token(api_token, root)
		project_exists = check_project_exists(bearer_token, root, project_name)
		if not project_exists
			puts "Creating project #{project_name}"
			create_project(bearer_token, root, project_name, version_name)
			puts "Successfully created project #{project_name}"
		end
	rescue BlackDuckApiError => e
		STDERR.puts("\tError: Black Duck API request failed. Request body below:")
		STDERR.puts e.message
		exit 1
	end
end

main()