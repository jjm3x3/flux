require "./game.rb"
require "./game_interface.rb"
require "./game_driver.rb"

debug=false

ARGV.each do |arg|
  if arg[0] == '-' && arg[1] == '-'
    if arg[2..-1] == "debug"
      debug=true
    end
  end
end

interface = CliInterface.new(debug)
gameDriver = GameDriver.new(Game.new(3, interface), 3, interface)
gameDriver.run




