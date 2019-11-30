require "./game.rb"
require "Tempfile"
require "io/console"

describe "game" do

    test_outfile = Tempfile.new 'test_output'

    it "should construct" do
        theTestInterface = TestInterface.new("some string", test_outfile)
        theGame = Game.new("some string", numberOfPlayers=3, theTestInterface)
    end 

    describe "draw3play2OfThem" do
        it "should leave one card remaining and play the others" do
            # setup
            input_stream = StringIO.new("0\n0\n")
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            theGame = Game.new(input_stream, numberOfPlayers=3, theTestInterface)
            theGame.deck = StackedDeck.new(theTestInterface) # this ensures that the card played doesn't require input of its own
            theFirstPlayer = theGame.players[0]

            # execute
            theGame.draw3play2OfThem(theFirstPlayer)

            # test
            expect(theTestInterface.cardList.size).to eq 1
        end
    end

    describe "discardAndDraw" do
        it "should not include this card when determining how many cards to draw" do
            # setup
            input_stream = StringIO.new("")
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            theGame = Game.new(input_stream, numberOfPlayers=3, theTestInterface)
            theFirstPlayer = theGame.players[0]
            firstPlayersOriginalCardsCount = theFirstPlayer.hand.size

            # execute
            theGame.discardAndDraw(theFirstPlayer)

            # test
            expect(theFirstPlayer.hand.size).to eq firstPlayersOriginalCardsCount - 1
        end
    end

    describe "useWhatYouTake" do
        # TODO:: This will break sometimes since it selects a card from a players hand
        #        Which was already established upon game construction therefor stacking
        #        the deck does not imporves this tests' flakyness. Instead we need a way
        #        of fixing the players hands so that this test doesn't fail
        it "should play a card at random from the selected player" do
            # setup
            input_stream = StringIO.new("0\n")
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            numberOfPlayers = 3
            theGame = Game.new(input_stream, numberOfPlayers, theTestInterface)
            theGame.deck = StackedDeck.new(theTestInterface) # this ensures that the card played doesn't require input of its own
            theFirstPlayer = theGame.players[0]
            theSecondPlayer = theGame.players[1]
            secondPlayersOriginalCardsCount = theSecondPlayer.hand.size

            # execute
            theGame.useWhatYouTake(theFirstPlayer)

            # test
            expect(theSecondPlayer.hand.size).to eq secondPlayersOriginalCardsCount - 1 # a stand in to make sure the right number of cards got played
        end

        # TODO: IDK how to test this
        # it "should not play any cards if no other player has a hand" do
        #     # setup
        #     input_stream = StringIO.new("0\n")
        #     theTestInterface = TestInterface.new(input_stream, test_outfile)
        #     numberOfPlayers = 3
        #     theGame = Game.new(input_stream, numberOfPlayers, theTestInterface)
        #     theGame.deck = StackedDeck.new(theTestInterface) # this ensures that the card played doesn't require input of its own
        #     theFirstPlayer = theGame.players[0]
        #     theSecondPlayer = theGame.players[1]
        #     secondPlayersOriginalCardsCount = theSecondPlayer.hand.size

        #     # execute
        #     theGame.useWhatYouTake(theFirstPlayer)

        #     # test
        #     expect(theSecondPlayer.hand.size).to eq secondPlayersOriginalCardsCount - 1 # a stand in to make sure the right number of cards got played
        # end
    end

    describe "taxation" do
        it "the first player should get some number of cards 1 less than the number of the players in game when the game is new" do
            # setup
            input_stream = StringIO.new("0\n0\n0\n")
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            numberOfPlayers = 3
            theGame = Game.new(input_stream, numberOfPlayers, theTestInterface)
            theFirstPlayer = theGame.players[0]
            firstPlayersOriginalCards = theFirstPlayer.hand

            # execute
            theGame.taxation(theFirstPlayer)

            # test
            expect(theFirstPlayer.hand.size).to eq firstPlayersOriginalCards.size + (numberOfPlayers-1)
        end

        it "the second and third players should get be down 1 card when the game is new" do
            # setup
            input_stream = StringIO.new("0\n0\n0\n")
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            numberOfPlayers = 3
            theGame = Game.new(input_stream, numberOfPlayers, theTestInterface)
            theFirstPlayer = theGame.players[0]
            theSecondPlayer = theGame.players[1]
            theThirdPlayer = theGame.players[2]
            secondPlayersOriginalCardsCount = theSecondPlayer.hand.size
            thridPlayersOriginalCardsCount = theThirdPlayer.hand.size

            # execute
            theGame.taxation(theFirstPlayer)

            # test
            expect(theSecondPlayer.hand.size).to eq secondPlayersOriginalCardsCount - 1
            expect(theThirdPlayer.hand.size).to eq thridPlayersOriginalCardsCount - 1
        end
    end

    describe "todaysSpecial" do
        it "should draw 3 cards" do
            # setup
            input_stream = StringIO.new("0\nn\nn\n")
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            theGame = Game.new(input_stream, numberOfPlayers=3, theTestInterface)
            theGame.deck = StackedDeck.new(theTestInterface) # this ensures that the card played doesn't require input of its own
            theFirstPlayer = theGame.players[0]
            deckCountBeforeExecution = theGame.deck.count

            # execute
            theGame.todaysSpecial(theFirstPlayer)

            # test
            expect(theGame.deck.count).to eq deckCountBeforeExecution - 3
        end

        it "should only play one card if it is not your birthday or a holiday" do
            # setup
            input_stream = StringIO.new("0\nn\nn\n")
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            theGame = Game.new(input_stream, numberOfPlayers=3, theTestInterface)
            theGame.deck = StackedDeck.new(theTestInterface) # this ensures that the card played doesn't require input of its own
            theFirstPlayer = theGame.players[0]
            deckCountBeforeExecution = theGame.deck.count

            # execute
            theGame.todaysSpecial(theFirstPlayer)

            # test
            expect(theFirstPlayer.keepers.size).to eq 1 # stand in for knowing how many cards got played
        end

        it "should only play two cards if it is not your birthday but is a holidy" do
            # setup
            input_stream = StringIO.new("0\nn\ny\n0\n")
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            theGame = Game.new(input_stream, numberOfPlayers=3, theTestInterface)
            theGame.deck = StackedDeck.new(theTestInterface) # this ensures that the card played doesn't require input of its own
            theFirstPlayer = theGame.players[0]
            deckCountBeforeExecution = theGame.deck.count

            # execute
            theGame.todaysSpecial(theFirstPlayer)

            # test
            expect(theFirstPlayer.keepers.size).to eq 2 # stand in for knowing how many cards got played
        end

        it "should play all three cards if it is you birthday" do
            # setup
            input_stream = StringIO.new("0\ny\n0\n0\n")
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            theGame = Game.new(input_stream, numberOfPlayers=3, theTestInterface)
            theGame.deck = StackedDeck.new(theTestInterface) # this ensures that the card played doesn't require input of its own
            theFirstPlayer = theGame.players[0]
            deckCountBeforeExecution = theGame.deck.count

            # execute
            theGame.todaysSpecial(theFirstPlayer)

            # test
            expect(theFirstPlayer.keepers.size).to eq 3 # stand in for knowing how many cards got played
        end
    end

    describe "mixItAllUp" do
        it "should maintain the same number of keepers" do
            # setup
            input_stream = StringIO.new("0")
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            theGame = Game.new(input_stream, numberOfPlayers=3, theTestInterface)
            theFirstPlayer = theGame.players[0]
            keeper1 = Keeper.new("Thing1")
            keeper2 = Keeper.new("thing2")
            theGame.players[0].keepers << keeper1
            theGame.players[1].keepers << keeper2
            allBeginningKeepers = theGame.players.flat_map do |player|
                player.keepers
            end

            # execute
            theGame.mixItAllUp(theFirstPlayer)

            # test
            allEndingKeepers = theGame.players.flat_map do |player|
                player.keepers
            end
            expect(allEndingKeepers.size).to eq allBeginningKeepers.size
        end
    end

    describe "letsDoThatAgain" do
        it "should non contain any keepers or goals" do
            # setup
            input_stream = StringIO.new("0")
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            theGame = Game.new(input_stream, numberOfPlayers=3, theTestInterface)
            theFirstPlayer = theGame.players[0]
            theGame.discardPile << Action.new(3, "jackpot2", "here are some rules")
            theGame.discardPile << Rule.new("some draw rule", 1, "Draw 9 cards")
            keeper1 = Keeper.new("Thing1")
            keeper2 = Keeper.new("thing2")
            theGame.discardPile << keeper1
            theGame.discardPile << keeper2
            theGame.discardPile << Goal.new("Achive me", [keeper1, keeper2] , "You most have these cards to win")

            # execute
            theGame.letsDoThatAgain(theFirstPlayer)

            # test
            theTestInterface.cardList.select do |card|
                expect(card.class).to_not eq Keeper
                expect(card.class).to_not eq Goal
            end
        end
    end

    describe "everyBodyGets1" do
        it "should draw one card per player" do
            # setup
            numberOfPlayers = 4
            input_stream = StringIO.new("0\n" * numberOfPlayers)
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            theGame = Game.new(input_stream, numberOfPlayers=3, theTestInterface)
            theFirstPlayer = theGame.players[0]
            originalDeckCount = theGame.deck.count

            # execute
            theGame.everyBodyGets1(theFirstPlayer)

            # test
            expect(theGame.deck.count).to eq originalDeckCount-theGame.players.length
        end

        it "each player should have one more card" do
            # setup
            numberOfPlayers = 4
            input_stream = StringIO.new("0\n" * numberOfPlayers)
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            theGame = Game.new(input_stream, numberOfPlayers=3, theTestInterface)
            theFirstPlayer = theGame.players[0]
            originalDeckCount = theGame.deck.count

            # execute
            theGame.everyBodyGets1(theFirstPlayer)

            # test
            theGame.players.select do |player|
                expect(player.hand.length).to eq 4 # since the opening hand size is 3
            end
        end
    end

    describe "tradeHands" do
        it "should not leave the first player with the same hand" do
            # setup
            input_stream = StringIO.new("0") # 0 indexed?
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            theGame = Game.new(input_stream, numberOfPlayers=3, theTestInterface)
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
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            theGame = Game.new(input_stream, numberOfPlayers=3, theTestInterface)
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
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            theGame = Game.new(input_stream, numberOfPlayers=3, theTestInterface)
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
                theTestInterface = TestInterface.new(input_stream, test_outfile)
                theGame = Game.new(input_stream, numberOfPlayers=3, theTestInterface)
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
                theTestInterface = TestInterface.new(input_stream, test_outfile)
                theGame = Game.new(input_stream, numberOfPlayers=3, theTestInterface)
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
                theTestInterface = TestInterface.new(input_stream, test_outfile)
                theGame = Game.new(input_stream, numberOfPlayers=3, theTestInterface)
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
                theTestInterface = TestInterface.new(input_stream, test_outfile)
                theGame = Game.new(input_stream, numberOfPlayers=3, theTestInterface)
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
                theTestInterface = TestInterface.new(input_stream, test_outfile)
                theGame = Game.new(input_stream, numberOfPlayers=3, theTestInterface)
                theFirstPlayer = theGame.players[0]
                theSecondPlayer = theGame.players[1]
                secondPlayersOriginalCards = theSecondPlayer.hand

                # execute
                theGame.rotateHands(theFirstPlayer)

                # test
                expect(theFirstPlayer.hand).to eq secondPlayersOriginalCards
            end

            it "second player should have the hand of the player after them" do
                # setup
                input_stream = StringIO.new("clockwise")
                theTestInterface = TestInterface.new(input_stream, test_outfile)
                theGame = Game.new(input_stream, numberOfPlayers=3, theTestInterface)
                theFirstPlayer = theGame.players[0]
                thePlayerAfterThem = theGame.players[2]
                playerAfterThemsCards = thePlayerAfterThem.hand

                # execute
                theGame.rotateHands(theFirstPlayer)

                # test
                theSecondPlayer = theGame.players[1]
                expect(theSecondPlayer.hand).to eq playerAfterThemsCards
            end
        end
    end

    test_outfile.unlink
end
