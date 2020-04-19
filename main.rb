require "./game.rb"
require "./game_interface.rb"
require "./game_driver.rb"
require "./game_gui.rb"

debug=false
gui=false

ARGV.each do |arg|
  if arg[0] == '-' && arg[1] == '-'
    if arg[2..-1] == "debug"
      debug=true
    end
    if arg[2..-1] == "gui"
      gui=true
    end
  end
end

if gui
  GameGui.new.show
else
  interface = CliInterface.new(debug)
  gameDriver = GameDriver.new(Game.new(3, interface), 3, interface)
  gameDriver.run
end
