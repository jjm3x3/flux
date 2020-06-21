#!/usr/local/bin/ruby
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

puts "starting game where debug: #{debug} and gui: #{gui}"


prompt_strings = {
  default: "Some default prompt",
  play_first_prompt: "Which one would you like to play first?",
  select_a_card_to_play_prompt: "Select a card from your hand to play"
}

logger = CliLogger.new(debug)
if gui
  guiGame = GameGui.new(logger, prompt_strings)
  guiGame.show
else
  players = Player.generate_players(3)
  cli_interface = CliInterface.new
  theGame = Game.new(logger, cli_interface, players)
  theGame.setup
  gameDriver = GameCli.new(theGame, logger, GameDriver.new(theGame, logger), cli_interface)
  gameDriver.run
end
