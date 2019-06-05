$:.unshift File.dirname(__FILE__)+'/lib'
require 'yaml'
require 'get_client_and_secret'
require 'deep_struct'
require 'json'
require 'salesforce_web_base'
require 'optparse'


AppName     = ARGV[0]
SandboxName = ARGV[1]
Username    = ARGV[2]
Password    = ARGV[3]



class GetClientAndSecret < SalesforceWebBase
    def to_page()
      if ! @on_page
        go(uri:'https://test.salesforce.com')
        login( username: Username+"."+SandboxName, password: Password )
        if @logged_in
          goto_page_from_link(linkname: 'Setup')
          goto_page_from_link(linkname: '^Apps$')
          goto_page_from_link(linkname: AppName)
          @on_page = true
        else
          puts "could not login"
        end
      end
    end



    def get_client_id()
      to_page()
      find_in_page('span', 'appsetup:setupForm:details:oauthSettingsSection:consumerKeySection:consumerKey')
    end

    def get_secret()
      to_page()
      find_hidden_by_link(linkname: 'Click to reveal')
    end
  end

getter = GetClientAndSecret.new('SandboxName', 'Username.SandboxName', 'Password')

client_key = getter.get_client_id()
secret = getter.get_secret()

my_object = { :client_key => "#{client_key}" , :secret => "#{secret}" }
puts JSON.pretty_generate(my_object)

getter.logout()