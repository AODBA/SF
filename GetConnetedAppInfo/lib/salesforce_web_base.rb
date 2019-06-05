$:.unshift File.dirname(__FILE__)

require 'mechanize'
require 'passwd_tools'

class SalesforceWebBase
  def initialize(env, user, pass)
    @agent = Mechanize.new
    if ENV[env] and ENV[env].length > 0
      env = ENV[env]
    end
    if ENV[user] and ENV[user].length > 0
      user = ENV[user]
    end
    @admin_username = "#{user}.#{env}"
    if ENV[pass] and ENV[pass].length > 0
      @admin_pw = ENV[pass]
    else
      @admin_pw = pass
    end

    @forcedToClassic = false
  end

  def login(args)
    if ! @logged_in
      @logged_in = false
      @page = @page.form('login') do |login_form|
        login_form.username = args[:username]
        login_form.un = args[:username]
        login_form.pw = args[:password]
      end.submit
      if @page.link_with(:text => /here/)
        @page = @page.link_with(:text => /here/).click
        if @page.link_with(text: /Logout/)
          @logged_in = true
        else
          if @page.title == "Lightning Experience"
            go(uri: "/ltng/switcher?destination=classic&referrer=%2Flightning%2Fsettings%2Fpersonal%2FSecurityCentral%2Fhome")
            if @page.link_with(text: /Logout/)
              @logged_in = true
            end
            @forcedToClassic = true
          end
        end
      end
    end
    @logged_in
  end

  def find_in_page(element_type, id)
    val = ''
    elm = @page.search("//#{element_type}[@id='#{id}']")
    if elm && elm.length > 0
      val = elm[0].text
    end
    val
  end

  def go(args)
    @page = @agent.get(args[:uri])
  end

  def goto_page_from_link(args)
    @page = @page.link_with(text: /#{args[:linkname]}/).click
    if /window.location.href[ ]*=[^']*'(?<uri>[^']*)/ =~ @page.body
      go(uri: uri)
    end
    @page
  end

  def is_link(args)
    if @page.link_with(text: /#{args[:linkname]}/)
      true
    else
      false
    end
  end

  def find_hidden_by_link(args)
    secret = ''
    link = @page.search("//*[text()='#{args[:linkname]}']")[0]
    if link && link[:onclick]
      if /; document.getElementById\('(?<id>[^']*)'\).style.display='block';/ =~ link[:onclick]
        secret = find_in_page('div', id)
      end
    end
    secret
  end

  def goto_page_by_name(args)
    @page.forms.each do |form|
      form.buttons.each do |button|
        if(button.name == args[:linkname])
          if /window.location.href[ ]*=[^']*'(?<uri>[^']*)/ =~ @page.body
            go(uri: uri)
          end
        end
      end
    end
    button = @page.search("//input[@name='#{args[:linkname]}']")[0]
    if button && button[:onclick]
      if /navigateToUrl\('(?<uri>[^']*)'.*\)/ =~ button[:onclick]
        go(uri: uri)
      end
    end

    @page
  end

  def submit_form(form_name, args={}, button_to_click='save')
    @logged_in = false
    the_form = @page.form(form_name)
    args.each do | field,value |
      the_form[field.to_s] = value
    end
    yield  the_form if block_given?
    button = the_form.button_with(button_to_click)
    @page = @agent.submit(the_form, button)
    if /window.location.href[ ]*=[^']*'(?<uri>[^']*)/ =~ @page.body
      go(uri: uri)
    end

    @page
  end

  def lookup_option(form, control_name, option)
    value = option
    form.field_with(name: control_name).options.each { |o|
      if o.text == option
        value = o.value
      end
    }
    value
  end

  def set_field_in_form_from_page(form, field_id)
    val = @page.search("//input[@id='#{field_id}']")[0][:value]
    form.add_field!(field_id, val)
  end

  def logout(args=nil)
    if @logged_in
      if @forcedToClassic
        go(uri: "/ltng/switcher?destination=lex-campaign" )
        go(uri: "/secur/logout.jsp")
        if @page.body =~ /Logout Page/
          @logged_in = false
        end
      else
        @page = @page.link_with(text: /Logout/).click

        if @page.body.include?('You have logged out of your salesforce.com session')
          @logged_in = false
        end
      end
    end
    ! @logged_in
  end

  def valid_result()
    @page.code == '200'
  end

end