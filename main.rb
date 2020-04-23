require "./game.rb"
require "./game_interface.rb"
require "./game_cli.rb"
require "./game_gui.rb"
require "./game_driver.rb"

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

logger = CliInterface.new(debug)
if gui
  guiGame = GameGui.new(logger)
  guiGame.show
else
  gameDriver = GameCli.new(GameDriver.new(Game.new(3, logger), logger), logger)
  gameDriver.run
end
