#!/usr/local/bin/ruby
require 'rubygems'
require 'mechanize'
require 'optparse'

class Controls
  URI = 'http://control.imdeasoftware.org/screenmate/ScreenMateChangeValuePage.aspx'
  USERNAME = 'imdea'
  PASSWORD = 'imdea'  
  BLINDS_ID = '3884056604'
  TEMP_ID = '3884056589'
  
  DEFAULT_BLINDS = 0
  DEFAULT_TEMP = 24.5
  
  def initialize(room)
    @agent = Mechanize.new
    @room = room

    # begin the session
    form = @agent.get(URI).form

    # login
    form.userName = USERNAME
    form.password = PASSWORD
    form = @agent.submit(form, form.buttons_with(:name => /loginButton/).first).form
    
    # choose the room
    form.roomId = room
    @agent.submit(form, form.buttons_with(:name => /lookUpRoomId/).first)
  end

  private
  
  def room_id
    "PLANTA_#{@room / 100}-Despacho_#{@room % 100}"
  end
  
  def control(obj, val)
    form = @agent.get(URI + "?objectIdRoot=#{room_id}&objectId=#{obj}").form
    form.newValue = val
    @agent.submit(form, form.buttons_with(:name => /saveButton/).first)
    nil
  end
  
  public
  
  def self.cmdline(args)
    room = nil
    blinds = nil
    temp = nil
    
    OptionParser.new do |opts|
      opts.banner = "Usage: #{File.basename $0} [options]"
      opts.on("-r", "--room ROOM", Integer, "Set the ROOM number") do |n|
        room = n
      end
      opts.on("-b", "--blinds NUM", Integer, "Set the blinds to NUM") do |n|
        blinds = n
      end
      opts.on("-t", "--temp TEMP", Float, "Set the TEMPerature") do |n|
        temp = n
      end
    end.parse!(args)
    
    abort("Must specify a room number.") unless room
        
    c = Controls.new(room) if blinds || temp
    c.blinds(blinds) if blinds
    c.temp(temp) if temp
  end
  
  def blinds(val = DEFAULT_BLINDS)
    control(BLINDS_ID, val)
    puts "blinds set to #{val}"
  end
  
  def temp(val = DEFAULT_TEMP)
    control(TEMP_ID, val)
    puts "temperature set to #{val}"
  end
end

# only when this script is invoked from from the command line
if __FILE__ == $0
  Controls.cmdline(ARGV)
end

