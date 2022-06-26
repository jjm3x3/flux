#!/usr/local/bin/ruby
require "Logger"
boot_strapping_logger = Logger.new("boot_strap.log")
boot_strapping_logger.debug "Starting up game!"

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
  opt.on("--log-level LEVEL") { |o| options[:log_level] = o }
  opt.on("--cli") { |o| options[:cli] = o }
  opt.on("--log-to-shell") { |o| options[:log_to_shell] = o }
end.parse!

log_level = (options[:log_level] ? options[:log_level] : Logger::DEBUG)
puts "starting game where log_level: #{log_level} and cli #{options[:cli] == true}"
boot_strapping_logger.info "starting game where log_level: #{log_level} and cli #{options[:cli] == true}"

output_stream = options[:log_to_shell] ? $stdout : "fluxx.log"
logger = Logger.new(output_stream)
logger.level = log_level

logger.debug "Starting up game!"
boot_strapping_logger.close  # the app/game logger can take it from here

the_deck = Deck.new(logger)
# the_deck = StackedDecks.stacked_deck_factory(logger, StackedDecks::QUICK_WIN)

if !options[:cli]
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
