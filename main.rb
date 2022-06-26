#!/usr/local/bin/ruby
require "optparse"
require "./game.rb"
require "./game_interface.rb"
require "./game_cli.rb"
require "./game_gui.rb"
require "./game_driver.rb"
require "./constants/prompts.rb"
require "./constants/stacked_decks.rb"

options = {}
OptionParser.new do |opt|
  opt.on("--debug") { |o| options[:debug] = o }
  opt.on("--log-level LEVEL") { |o| options[:log_level] = o }
  opt.on("--gui") { |o| options[:gui] = o }
end.parse!

puts "starting game where debug: #{options[:debug] == true} and gui: #{options[:gui] == true}"

logger = Logger.new($stdout)
logger.level = options[:debug] ? Logger::DEBUG : Logger::INFO

the_deck = Deck.new(logger)
# the_deck = StackedDecks.stacked_deck_factory(logger, StackedDecks::QUICK_WIN)

if options[:gui]
  guiGame = GameGui.new(logger, Constants::PROMPT_STRINGS, Constants::USER_SPECIFIC_PROMPTS, the_deck)
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
