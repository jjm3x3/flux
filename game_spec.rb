require "./game.rb"
require "Tempfile"

describe "game" do

    test_oufile = Tempfile.new 'test_output'

    it "should construct" do
        Game.new("input_stream", test_oufile)
    end 

    describe "tradeHands" do
        it "should not leave the first player with the same hand" do
            # setup
            input_stream = StringIO.new("0") # 0 indexed?
            theGame = Game.new(input_stream, test_oufile)
            theFirstPlayer = theGame.players[0]
            firstPlayersOriginalCards = theFirstPlayer.hand

            # execute
            theGame.tradeHands(theFirstPlayer)

            # test
            expect(theFirstPlayer.hand).not_to eq firstPlayersOriginalCards
        end

        it "should trade the two hands" do
            # setup
            input_stream = StringIO.new("0") # 0 indexed?
            theGame = Game.new(input_stream, test_oufile)
            theFirstPlayer = theGame.players[0]
            theSecondPlayer = theGame.players[1]
            firstPlayersOriginalCards = theFirstPlayer.hand
            secondPlayersOriginalCards = theSecondPlayer.hand

            # execute
            theGame.tradeHands(theFirstPlayer)

            # test
            expect(theFirstPlayer.hand).to eq secondPlayersOriginalCards
            expect(theSecondPlayer.hand).to eq firstPlayersOriginalCards
        end

        it "every other players hands should remain untouched" do
            # setup
            input_stream = StringIO.new("0") # 0 indexed?
            theGame = Game.new(input_stream, test_oufile)
            theFirstPlayer = theGame.players[0]
            theOtherPlayer = theGame.players[2]
            otherPlayersOriginalCards = theOtherPlayer.hand

            # execute
            theGame.tradeHands(theFirstPlayer)

            # test
            expect(theOtherPlayer.hand).to eq otherPlayersOriginalCards
        end
    end

    describe "rotate_hands" do
        describe "counter clockwise" do
            it "first player should not have the hand they started with" do
                # setup
                input_stream = StringIO.new("thing")
                theGame = Game.new(input_stream, test_oufile)
                theFirstPlayer = theGame.players[0]
                firstPlayersOriginalCards = theFirstPlayer.hand

                # execute
                theGame.rotateHands(theFirstPlayer)

                # test
                expect(theFirstPlayer.hand).not_to eq firstPlayersOriginalCards
            end

            it "first player should have the hand of the last player" do
                # setup
                input_stream = StringIO.new("thing")
                theGame = Game.new(input_stream, test_oufile)
                theFirstPlayer = theGame.players[0]
                theLastPlayer = theGame.players[theGame.players.length-1]
                lastPlayersOriginalCards = theLastPlayer.hand

                # execute
                theGame.rotateHands(theFirstPlayer)

                # test
                expect(theFirstPlayer.hand).to eq lastPlayersOriginalCards
            end

            it "second player should have the hand of the first player" do
                # setup
                input_stream = StringIO.new("thing")
                theGame = Game.new(input_stream, test_oufile)
                theFirstPlayer = theGame.players[0]
                firstPlayersOriginalCards = theFirstPlayer.hand

                # execute
                theGame.rotateHands(theFirstPlayer)

                # test
                theSecondPlayer = theGame.players[1]
                expect(theSecondPlayer.hand).to eq firstPlayersOriginalCards
            end
        end

        describe "clockwise" do
            it "first player should not have the hand they started with" do
                # setup
                input_stream = StringIO.new("clockwise")
                theGame = Game.new(input_stream, test_oufile)
                theFirstPlayer = theGame.players[0]
                firstPlayersOriginalCards = theFirstPlayer.hand

                # execute
                theGame.rotateHands(theFirstPlayer)

                # test
                expect(theFirstPlayer.hand).not_to eq firstPlayersOriginalCards
            end

            it "first player should have the hand of the second player" do
                # setup
                input_stream = StringIO.new("clockwise")
                theGame = Game.new(input_stream, test_oufile)
                theFirstPlayer = theGame.players[0]
                theSecondPlayer = theGame.players[1]
                secondPlayersOriginalCards = theSecondPlayer.hand

                # execute
                theGame.rotateHands(theFirstPlayer)

                # test
                expect(theFirstPlayer.hand).to eq secondPlayersOriginalCards
            end

            it "second player should have the hand of the last player" do
                # setup
                input_stream = StringIO.new("clockwise")
                theGame = Game.new(input_stream, test_oufile)
                theFirstPlayer = theGame.players[0]
                theLastPlayer = theGame.players[theGame.players.length-1]
                lastPlayersOriginalCards = theLastPlayer.hand

                # execute
                theGame.rotateHands(theFirstPlayer)

                # test
                theSecondPlayer = theGame.players[1]
                expect(theSecondPlayer.hand).to eq lastPlayersOriginalCards
            end
        end
    end

    test_oufile.unlink
end
