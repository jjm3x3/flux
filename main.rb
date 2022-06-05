#!/usr/local/bin/ruby
require "./game.rb"
require "./game_interface.rb"
require "./game_cli.rb"
require "./game_gui.rb"
require "./game_driver.rb"
require "./constants/prompts.rb"
require "./constants/stacked_decks.rb"

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

logger = Logger.new($stdout)
logger.level = debug ? Logger::DEBUG : Logger::INFO

# the_deck = Deck.new(logger)
the_deck = StackedDecks.stacked_deck_factory(logger, StackedDecks::QUICK_WIN)

if gui
  guiGame = GameGui.new(logger, Constants::PROMPT_STRINGS, Constants::USER_SPECIFIC_PROMPTS)
  guiGame.show
else
  players = Player.generate_players(3)
  player_prompts = PlayerPromptGenerator.generate_prompts(players, Constants::USER_SPECIFIC_PROMPTS)
  prompt_strings = Constants::PROMPT_STRINGS.merge(player_prompts)
  cli_interface = CliInterface.new(prompt_strings)
  theGame = Game.new(logger, cli_interface, players, Random.new, the_deck)
  theGame.setup
  gameDriver = GameCli.new(theGame, logger, GameDriver.new(theGame, logger), cli_interface)
  gameDriver.run
end
