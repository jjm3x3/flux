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
  discard_down_to_keeper_limit: "Choose a keeper to discard",
  play_first_prompt: "Which one would you like to play first?",
  play_next_prompt: "which would you like to play next?",
  which_player_to_pick_from_prompt: "which player would you like to pick from",
  select_a_card_to_play_prompt: "Select a card from your hand to play",
  choose_card_to_play_prompt: "pick a card to play",
  birthday_prompt: "is today your birthday",
  holiday_anniversary_prompt: "Is today a holiday or an anniversary",
  replay_prompt: "pick a card you would like to replay",
  trade_hands_prompt: "who would you like to trade hands with?",
  rotation_prompt: "Which way would you like to rotate?",
  pick_a_keeper_from_prompt: "Which player would you like to take a keeper from",
  are_you_sure_no_trade_prompt: "Are you sure you don't want to trade with anyone?",
  select_a_keeper_prompt: "Slect which Keeper you would like",
  keeper_to_give_prompt: "Which player would you like to take a keeper from",
  death_discard_prompt: "Which permanent would you like to discard to death?"
}

logger = CliLogger.new(debug)
if gui
  guiGame = GameGui.new(logger, prompt_strings)
  guiGame.show
else
  players = Player.generate_players(3)
  cli_interface = CliInterface.new(prompt_strings)
  theGame = Game.new(logger, cli_interface, players)
  theGame.setup
  gameDriver = GameCli.new(theGame, logger, GameDriver.new(theGame, logger), cli_interface)
  gameDriver.run
end
