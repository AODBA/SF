require 'restforce'
require 'get_client_and_secret'

class SalesforceAPIBase

  def initialize(sandbox, user, pass)
    Restforce.configure do |config|
      config.api_version = "32.0"
      config.host = 'test.salesforce.com'
    end
    if ENV[pass] and ENV[pass].length > 0
      admin_pw = ENV[pass]
    else
      admin_pw = pass
    end
    getter = GetClientAndSecret.new(sandbox, user, pass)
    @client_key = getter.get_client_id()
    @secret = getter.get_secret()
    getter.logout()
    @client = Restforce.new ({  username: "#{user}.#{sandbox}",
                                password: admin_pw,
                                client_id: client_key,
                                client_secret: secret
    })
  end

  def client_id()
    return @client_id
  end

  def client_secret()
    return @client_secret
  end

  def describe_object(object)
    setting = @client.describe(object)
    puts "Fields for Object #{object}"
    setting.fields.each do |f|
      puts f[:name]
    end
    puts '==============================='
  end

  def show_all_objects
    objects = @client.api_get "sobjects/"
    puts 'list of all objects'
    objects.body.sobjects.each do |o|
      puts o.name
    end
    puts '==============================='
  end

  def logout
    true
  end

  def client
    @client
  end
end