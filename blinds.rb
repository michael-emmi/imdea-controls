#!/usr/local/bin/ruby
require 'rubygems'
require 'mechanize'
require 'optparse'
require 'yaml'

$loud = false

class Controls
  URI = 'http://control.imdeasoftware.org/screenmate/ScreenMateChangeValuePage.aspx'
  
  IDS = {
    temperature_setting: '3884056589',
    sunblind_control: '3884056587',
    sunblind_setting: '3884056604',
    door_light_control: '3884056590',
    door_light_setting: '3884056581',
    window_light_control: '3884056601',
    window_light_setting: '3884056602'
  }
  
  DEFAULTS = {
    sunblind: 0,
    temperature: 24.5,
    window_light: 0,
    door_light: 0
  }
  
  def initialize(username, password, room)
    @agent = Mechanize.new
    @username = username
    @password = password
    @room = room

    # begin the session
    print "opening session... " if $loud
    form = @agent.get(URI).form
    puts "OK" if $loud && form
    abort "Could not open session." unless form

    # login
    form.userName = @username
    form.password = @password
    print "logging in... " if $loud
    form = @agent.submit(form, form.buttons_with(:name => /loginButton/).first).form
    puts "OK" if $loud && form
    abort "could not log in as #{@username}." unless form
    
    # choose the room
    form.roomId = @room
    print "selecting room... " if $loud
    page = @agent.submit(form, form.buttons_with(:name => /lookUpRoomId/).first)
    puts "OK" if $loud && page
    abort "could not select room #{room}." unless page
  end

  private
  
  def room_id
    "PLANTA_#{@room / 100}-Despacho_#{@room % 100}"
  end
  
  def control(obj, val)
    form = @agent.get(URI + "?objectIdRoot=#{room_id}&objectId=#{obj}").form
    form.newValue = val
    print "setting controls... " if $loud
    page = @agent.submit(form, form.buttons_with(:name => /saveButton/).first)
    puts "OK" if $loud && page
    abort "control command failed." unless page
    nil
  end
  
  public
  
  def self.cmdline(args)
    room = nil
    blinds = nil
    temp = nil
    window = nil
    door = nil
    username = nil
    password = nil
    
    cfg = {}
    ['~','.'].each do |path|
      cfgfile = File.join(path, '.blinds.yml')
      if File.exists? cfgfile then
        # puts "Loading configuration file #{cfgfile}"
        cfg = YAML::load_file(cfgfile)
        break
      end
    end
    
    OptionParser.new do |opts|
      opts.banner = "Usage: #{File.basename $0} [options]"
      opts.on("-u", "--username USERNAME", "Your USERNAME") do |n|
        username = n
      end
      opts.on("-p", "--password PASSWORD", "Your PASSWORD") do |n|
        password = n
      end
      opts.on("-r", "--room ROOM", Integer, "Set the ROOM number") do |n|
        room = n
      end
      opts.on("-b", "--blinds NUM", Integer, "Set the blinds to NUM") do |n|
        blinds = n
      end
      opts.on("-t", "--temp TEMP", Float, "Set the TEMPerature") do |n|
        temp = n
      end
      opts.on("-w", "--window LIGHT", Float, "Set the window LIGHT") do |n|
        window = n
      end
      opts.on("-d", "--door LIGHT", Float, "Set the door LIGHT") do |n|
        door = n
      end
      opts.on("-l", "--lights LIGHT", Float, "Set all the LIGHTS") do |n|
        window = n
        door = n
      end
      opts.on("-v", "--verbose") do |v|
        $loud = v
      end
    end.parse!(args)
    
    username ||= cfg['username']
    password ||= cfg['password']
    room ||= cfg['room_no'].to_i
    
    abort("Must specify a username.") unless username
    abort("Must specify a password.") unless password
    abort("Must specify a room number.") unless room
    
    c = Controls.new(username, password, room) if blinds || temp || window || door
    c.sunblind(blinds) if blinds
    c.temperature(temp) if temp
    c.window_light(window) if window
    c.door_light(door) if door
  end
  
  [:sunblind, :temperature, :window_light, :door_light].each do |x|
    define_method(x) do |val|
      val ||= DEFAULTS[x]
      control( IDS[:"#{x}_setting"], val )
      puts "#{x.to_s.gsub(/_/,' ')} set to #{val}"
    end
  end
end

Controls.cmdline(ARGV) if __FILE__ == $0
