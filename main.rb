#!/usr/local/bin/ruby
require "./game.rb"
require "./game_interface.rb"
require "./game_cli.rb"
require "./game_gui.rb"
require "./game_driver.rb"
require "./constants/prompts.rb"

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

puts "starting game where debug: #{debug} and gui: #{gui}"


user_specific_prompts = {
  discard_prompt_name: {
      key_template: "discard_down_to_limit_{name}",
      value_template: "Player {name} Select a card to discard"}
}

logger = CliLogger.new(debug)
if gui
  guiGame = GameGui.new(logger, Constants::PROMPT_STRINGS)
  guiGame.show
else
  players = Player.generate_players(3)
  cli_interface = CliInterface.new(Constants::PROMPT_STRINGS)
  theGame = Game.new(logger, cli_interface, players)
  theGame.setup
  gameDriver = GameCli.new(theGame, logger, GameDriver.new(theGame, logger), cli_interface)
  gameDriver.run
end
