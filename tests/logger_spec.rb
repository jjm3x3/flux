require "Tempfile"
require "./game_interface.rb"
require "./player.rb"
require "./deck.rb"
require "./logger.rb"

describe "BaseLogger" do

    test_outfile = Tempfile.new 'test_output'

    describe "log_cards" do
        it "should print cards only using their to_s form" do
            #setup
            logger = TestLogger.new("some string", test_outfile)

            test_player = Player.new("test player")
            test_deck = Deck.new(logger)
            test_player.set_hand(test_deck.drawCards(3))

            # execute
            logger.log_cards(test_player.hand)

            #test
            # no reall assertions for now... change test to see output
        end

        it "should print a players keepers only using their to_s form" do
            #setup
            # logger = CliLogger.new(debug=true)
            logger = TestLogger.new("some string", test_outfile)

            test_keeper = Keeper.new(100, "A Test")
            test_player = Player.new("test player")
            test_player.add_permanent(test_keeper)

            # execute
            logger.log_cards(test_player.keepers)

            #test
            # no reall assertions for now... change test to see output
        end
    end

    test_outfile.unlink
end