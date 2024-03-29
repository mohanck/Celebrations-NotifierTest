require 'google/apis/admin_directory_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'

require 'fileutils'

OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
APPLICATION_NAME = 'Directory API Ruby Quickstart'
CLIENT_SECRETS_PATH = 'client_secret.json'
CREDENTIALS_PATH = File.join(Dir.home, '.credentials',
                             "admin-directory_v1-ruby-quickstart.yaml")
SCOPE = Google::Apis::AdminDirectoryV1::AUTH_ADMIN_DIRECTORY_USER_READONLY

##
# Ensure valid credentials, either by restoring from the saved credentials
# files or intitiating an OAuth2 authorization. If authorization is required,
# the user's default browser will be launched to approve the request.
#
# @return [Google::Auth::UserRefreshCredentials] OAuth2 credentials
def authorize
  FileUtils.mkdir_p(File.dirname(CREDENTIALS_PATH))

  client_id = Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
  token_store = Google::Auth::Stores::FileTokenStore.new(file: CREDENTIALS_PATH)
  authorizer = Google::Auth::UserAuthorizer.new(
    client_id, SCOPE, token_store)
  user_id = 'default'
  credentials = authorizer.get_credentials(user_id)
  if credentials.nil?
    url = authorizer.get_authorization_url(
      base_url: OOB_URI)
    puts "Open the following URL in the browser and enter the " +
           "resulting code after authorization"
    puts url
    code = gets
    credentials = authorizer.get_and_store_credentials_from_code(
      user_id: user_id, code: code, base_url: OOB_URI)
  end
  credentials
end

# Initialize the API
service = Google::Apis::AdminDirectoryV1::DirectoryService.new
service.client_options.application_name = APPLICATION_NAME
service.authorization = authorize
# List the first 10 users in the domain
response = service.list_users(domain: 'appfolio.com',
                              order_by: 'email',
                              max_results: 500,
                              view_type: 'domain_public')
puts "Users:"
puts "No users found" if response.users.empty?
response.users.each { |user| puts "- #{user.primary_email} (#{user.name.full_name})" }
puts response.users.count
puts response.inspect
response = service.list_users(domain: 'appfolio.com',
                              order_by: 'email',
                              max_results: 500,
                              view_type: 'domain_public',
                              page_token: response.next_page_token)

response.users.each { |user| puts "- #{user.primary_email} (#{user.name.full_name})" }
puts response.users.count
