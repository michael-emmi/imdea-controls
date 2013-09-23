#!/usr/bin/env ruby
require 'mechanize'

class Controls
  URI = 'http://control.imdeasoftware.org/screenmate/ScreenMateChangeValuePage.aspx'
  USERNAME = 'imdea'
  PASSWORD = 'imdea'  
  BLINDS_ID = '3884056604'
  TEMP_ID = '3884056589'
  
  def initialize(room)
    @agent = Mechanize.new
    @room = room
    @room_id = "PLANTA_#{room / 100}-Despacho_#{room % 100}"

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
  
  def control(obj, val)
    form = @agent.get(URI + "?objectIdRoot=#{@room_id}&objectId=#{obj}").form
    form.newValue = val
    @agent.submit(form, form.buttons_with(:name => /saveButton/).first)
  end
  
  public
  
  def blinds(val = 0)
    control(BLINDS_ID, val)
  end
  
  def temp(val = 24.0)
    control(TEMP_ID, val)
  end
end

room = 358
blinds = ARGV[0] 
  
c = Controls.new(room)
c.blinds(ARGV[0])
