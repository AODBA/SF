$:.unshift File.dirname(__FILE__)
require 'salesforce_web_base'

class GetClientAndSecret < SalesforceWebBase
  def to_page()
    if ! @on_page
      go(uri:'https://test.salesforce.com')
     # login( username: 'x.x@x.edu.au.base1', password: 'xxxxxx' )
      login( username: '#{Username}.#{SandboxName}', password: '#{Password}' )
      if @logged_in
        goto_page_from_link(linkname: 'Setup')
        goto_page_from_link(linkname: '^Apps$')
        goto_page_from_link(linkname: 'sfdxConnect')
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

