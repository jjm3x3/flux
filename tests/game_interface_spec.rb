require "Tempfile"
require "./game_interface.rb"
require "./player.rb"
require "./deck.rb"

describe "GameInterface" do

    test_outfile = Tempfile.new 'test_output'

    it "should print cards only using their to_s form" do
        #setup
        logger = TestInterface.new("some string", test_outfile)

        test_player = Player.new("test player")
        test_deck = Deck.new(logger)
        test_player.set_hand(test_deck.drawCards(3))

        # execute
        logger.displayCardsDebug(test_player.hand)

        #test
        # no reall assertions for now... change test to see output
    end

    test_outfile.unlink
end