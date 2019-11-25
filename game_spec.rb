require "./game.rb"
require "Tempfile"

describe "game" do

    test_oufile = Tempfile.new 'test_output'

    it "should construct" do
        Game.new("input_stream", test_oufile)
    end 

    describe "rotate_hands" do
        it "first player should not have the hand they started with" do
            # setup
            input_stream = StringIO.new("thing")
            theGame = Game.new(input_stream, test_oufile)
            theFirstPlayer = theGame.players[0]
            firstPlayersOriginalCards = theFirstPlayer.hand

            # execute
            theGame.rotateHands(theFirstPlayer)

            # test
            expect(firstPlayersOriginalCards).not_to eq theFirstPlayer.hand
        end
    end

    test_oufile.unlink
end
