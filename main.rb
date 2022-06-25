#!/usr/local/bin/ruby
require "Logger"
boot_strapping_logger = Logger.new("boot_strap.log")
boot_strapping_logger.debug "Starting up game!"

loop do
  begin
    boot_strapping_logger.info "requiring deps"
    require "optparse"
    boot_strapping_logger.info "optparse required"
    require "./game.rb"
    boot_strapping_logger.info "game.rb required"
    # TODO:: known issue with requireing game_interface which requires concurrent
    #        seems like concurrent-ruby does some logger intialization which leads
    #        to a warning like
    #        `already initialized constant Logger::ProgName`
    #        there doesn't seem to be any practical issue with this at this time.
    require "./game_interface.rb"
    boot_strapping_logger.info "game_interface.rb required"
    require "./game_cli.rb"
    boot_strapping_logger.info "game_cli.rb required"
    require "./game_gui.rb"
    boot_strapping_logger.info "game_gui.rb required"
    require "./game_driver.rb"
    boot_strapping_logger.info "game_driver.rb required"
    require "./constants/prompts.rb"
    boot_strapping_logger.info "constants/prompts.rb required"
    require "./constants/stacked_decks.rb"
    boot_strapping_logger.info "constants/stacked_decks.rb required"
    break
  rescue LoadError => ex
    boot_strapping_logger.debug "loading some lib failed because: #{ex}"
    boot_strapping_logger.debug "Stacktrace: #{ex.backtrace}"
    boot_strapping_logger.debug "Stacktrace: #{ex.backtrace.inspect}"
  end
  sleep_duration = 10
  boot_strapping_logger.debug "Going to sleep and try in #{sleep_duration} sec(s)..."
  sleep sleep_duration
end

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

if options[:cli]
  players = Player.generate_players(3)
  player_prompts = PlayerPromptGenerator.generate_prompts(players, Constants::USER_SPECIFIC_PROMPTS)
  prompt_strings = Constants::PROMPT_STRINGS.merge(player_prompts)
  cli_interface = CliInterface.new(prompt_strings)
  theGame = Game.new(logger, cli_interface, players, Random.new, the_deck)
  theGame.setup
  gameDriver = GameCli.new(theGame, logger, GameDriver.new(theGame, logger), cli_interface)
  gameDriver.run
else
  guiGame = nil

  loop do
    begin
      guiGame = GameGui.new(logger, Constants::PROMPT_STRINGS, Constants::USER_SPECIFIC_PROMPTS, the_deck)
      break
    rescue Exception => ex
      logger.debug "Creating game failed because: #{ex}"
      logger.debug "Stacktrace: #{ex.backtrace}"
      logger.debug "Stacktrace: #{ex.backtrace.inspect}"
    end
    sleep_duration = 10
    logger.debug "Going to sleep and try in #{sleep_duration} sec(s)..."
    sleep sleep_duration
  end

  guiGame.show
end
