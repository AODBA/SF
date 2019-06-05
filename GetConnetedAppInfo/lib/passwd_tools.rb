require 'base64'
require 'optparse'

class PasswdTools
  def self.encode(pw)
    Base64.encode64(pw)
  end

  def self.decode(pw)
    Base64.decode64(pw)
  end
end
