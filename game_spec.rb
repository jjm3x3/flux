require "./game.rb"
require "Tempfile"
require "io/console"

describe "game" do

    test_outfile = Tempfile.new 'test_output'

    it "should construct" do
        theTestInterface = TestInterface.new("some string", test_outfile)
        theGame = Game.new(numberOfPlayers=3, theTestInterface)
    end

    describe "activePlayer" do
        it "should not modify the current player instnace variable" do
            # setup
            input_stream = StringIO.new("")
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            theGame = Game.new(numberOfPlayers=3, theTestInterface)
            theGame.currentPlayerCounter = 10

            # execute
            theGame.activePlayer

            # test
            expect(theGame.currentPlayerCounter).to eq 10
        end
    end

    describe "drawCards" do
        it "should draw bassed on the 'drawRule' if the count parmeter is :draw_rule" do
            # setup
            input_stream = StringIO.new("")
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            theGame = Game.new(numberOfPlayers=3, theTestInterface)
            theGame.deck = StackedDeck.new(theTestInterface)
            theFirstPlayer = theGame.players[0]
            theDecksOriginalSize = theGame.deck.count

            # execute
            theGame.drawCards(theFirstPlayer, :draw_rule)

            # test
            expect(theGame.deck.count).to eq theDecksOriginalSize - theGame.ruleBase.drawRule
        end

        it "should draw enough cards including creepers to make sure it returns the expected number" do
            # setup
            input_stream = StringIO.new("")
            theTestInterface = TestInterface.new(input_stream,test_outfile)
            theGame = Game.new(numberOfPlayers=3, theTestInterface)
            theGame.deck = StackedDeck.new(theTestInterface, [Creeper.new(10000, "Screem", "Some very scary rule text")])
            theFirstPlayer = theGame.players[0]

            # execute
            returnedCards = theGame.drawCards(theFirstPlayer, :draw_rule)

            # test
            expect(returnedCards.length).to eq theGame.ruleBase.drawRule
        end

        it "should never return any creepers" do
            # setup
            input_stream = StringIO.new("")
            theTestInterface = TestInterface.new(input_stream,test_outfile)
            theGame = Game.new(numberOfPlayers=3, theTestInterface)
            theGame.deck = StackedDeck.new(theTestInterface,
                [Creeper.new(10000, "Screem", "Some very scary rule text"),
                Creeper.new(10001, "Lonelyness", "There is no one there"),
                Creeper.new(10002, "Depression", "There is no one there"),
                Creeper.new(10003, "Bankrupsy", "There is no one there"),
                Creeper.new(10004, "Lust", "There is no one there"),
                Creeper.new(10005, "Loss", "There is no one there")])
            theFirstPlayer = theGame.players[0]

            # execute
            returnedCards = theGame.drawCards(theFirstPlayer, :draw_rule)

            # test
            returnedCards.each do |card|
                expect(card.card_type).to_not eq "Creeper"
            end
        end

        it "should draw enough cards including any number of creepers to make sure it returns the expected number" do
            # setup
            input_stream = StringIO.new("")
            theTestInterface = TestInterface.new(input_stream,test_outfile)
            theGame = Game.new(numberOfPlayers=3, theTestInterface)
            theGame.deck = StackedDeck.new(theTestInterface,
                [Creeper.new(10000, "Screem", "Some very scary rule text"),
                Creeper.new(10001, "Lonelyness", "There is no one there")])
            theFirstPlayer = theGame.players[0]

            # execute
            returnedCards = theGame.drawCards(theFirstPlayer, :draw_rule)

            # test
            expect(returnedCards.length).to eq theGame.ruleBase.drawRule
        end
    end

    describe "playCards" do
        it "should play cards..... :?" do
            # setup
            input_stream = StringIO.new("0\n")
            theTestInterface = TestInterface.new(input_stream,test_outfile)
            theGame = Game.new(numberOfPlayers=3, theTestInterface)
            theFirstPlayer = theGame.players[0].hand.unshift(FakeCard.new("thing1"))
            theGame.currentPlayerCounter = 0

            # execute
            theGame.playCards

            # test
        end
    end

    describe "removeDownToKeeperLimit" do
        it "should make sure that the player has no more keepers than the current keeper limit" do
            # setup
            input_stream = StringIO.new("0\n")
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            theGame = Game.new(numberOfPlayers=3, theTestInterface)
            theFirstPlayer = theGame.players[0]
            theFirstPlayer.keepers = [Keeper.new("thing1"), Keeper.new("thing2"), Keeper.new("thing3")]
            keeperLimit = 2
            theGame.ruleBase.addRule(Limit.new("keeper limit 2", 4, "some dumb rules text", keeperLimit))

            # execute
            theGame.removeDownToKeeperLimit(theFirstPlayer)

            # test
            expect(theFirstPlayer.keepers.size).to eq keeperLimit
        end
    end

    describe "removeDownToHandLimit" do
        it "should make sure that the player has no more keepers than the current keeper limit" do
            # setup
            input_stream = StringIO.new("0\n")
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            theGame = Game.new(numberOfPlayers=3, theTestInterface)
            theFirstPlayer = theGame.players[0]
            handLimit = 2
            theGame.ruleBase.addRule(Limit.new("hand limit 2", 3, "some dumb rules text", handLimit))

            # execute
            theGame.discardDownToLimit(theFirstPlayer)

            # test
            expect(theFirstPlayer.hand.size).to eq handLimit
        end
    end

    describe "replenishHand" do
        it "should return the same number of cards if none are to be drawn" do
            # setup
            input_stream = StringIO.new("")
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            theGame = Game.new(numberOfPlayers=3, theTestInterface)
            theFirstPlayer = theGame.players[0]
            # assuming the start draw rule is 1
            cardsDrawnToDate = 1

            # execute
            totalDrawnCards = theGame.replenishHand(cardsDrawnToDate, theFirstPlayer)

            # test
            expect(totalDrawnCards).to eq cardsDrawnToDate
        end

        it "should return a number greater if there are cards to be drawn" do
            # setup
            input_stream = StringIO.new("")
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            theGame = Game.new(numberOfPlayers=3, theTestInterface)
            theFirstPlayer = theGame.players[0]
            # assuming the start draw rule is 1
            cardsDrawnToDate = 0

            # execute
            totalDrawnCards = theGame.replenishHand(cardsDrawnToDate, theFirstPlayer)

            # test
            expect(totalDrawnCards).to be > cardsDrawnToDate
        end

        it "should remove cards from the deck if it draws cards" do
            # setup
            input_stream = StringIO.new("")
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            theGame = Game.new(numberOfPlayers=3, theTestInterface)
            theFirstPlayer = theGame.players[0]
            # assuming the start draw rule is 1
            cardsDrawnToDate = 0
            countOfDeckToStart = theGame.deck.count

            # execute
            totalDrawnCards = theGame.replenishHand(cardsDrawnToDate, theFirstPlayer)

            # test
            expect(theGame.deck.count).to eq countOfDeckToStart - totalDrawnCards
        end

        it "should play creepers imidately if they are drawn" do
            # setup
            input_stream = StringIO.new("")
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            theGame = Game.new(numberOfPlayers=3, theTestInterface)
            warCreeper = Creeper.new(1, "War", "with some rules text")
            theGame.deck = StackedDeck.new(theTestInterface, [warCreeper])
            theFirstPlayer = theGame.players[0]
            # assuming the start draw rule is 1
            cardsDrawnToDate = 0

            # execute
            totalDrawnCards = theGame.replenishHand(cardsDrawnToDate, theFirstPlayer)

            # test
            expect(theFirstPlayer.creepers).to include warCreeper
        end

        it "should remove expected number plus the number of creeper cards from deck" do
            # setup
            input_stream = StringIO.new("")
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            theGame = Game.new(numberOfPlayers=3, theTestInterface)
            warCreeper = Creeper.new(1, "War", "with some rules text")
            theGame.deck = StackedDeck.new(theTestInterface, [warCreeper])
            theFirstPlayer = theGame.players[0]
            # assuming the start draw rule is 1
            cardsDrawnToDate = 0
            countOfDeckToStart = theGame.deck.count

            # execute
            totalDrawnCards = theGame.replenishHand(cardsDrawnToDate, theFirstPlayer)

            # test
            expect(theGame.deck.count).to eq countOfDeckToStart - (totalDrawnCards + 1) # the creeper
        end
    end

    describe "winner" do
        it "should be false for a brand new game" do
            # setup
            input_stream = StringIO.new("")
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            theGame = Game.new(numberOfPlayers=3, theTestInterface)

            # execute , test
            expect(theGame.winner).to be false
        end
    end

    describe "opponents" do
        it "should only get the opponents of the active player if no player is passed in" do
            # setup
            input_stream = StringIO.new("")
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            theGame = Game.new(numberOfPlayers=3, theTestInterface)
            currentPlayerCounter = 0 # set active player to "player1"

            # execute
            theOpponents = theGame.opponents


            # test
            expect(theOpponents).to_not include theGame.players[0]
            expect(theOpponents).to include theGame.players[1]
            expect(theOpponents).to include theGame.players[2]
        end

        it "should only get the opponents of the player that is passed in" do
            # setup
            input_stream = StringIO.new("")
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            theGame = Game.new(numberOfPlayers=3, theTestInterface)
            currentPlayerCounter = 0 # set active player to "player1"

            # execute
            theOpponents = theGame.opponents(theGame.players[1])


            # test
            expect(theOpponents).to include theGame.players[0]
            expect(theOpponents).to_not include theGame.players[1]
            expect(theOpponents).to include theGame.players[2]
        end
    end

    describe "jackpot!" do
        it "should draw 3 cards from the deck" do
            # setup
            input_stream = StringIO.new("")
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            theGame = Game.new(numberOfPlayers=3, theTestInterface)
            theGame.deck = StackedDeck.new(theTestInterface) # this ensures that the card played doesn't require input of its own
            theFirstPlayer = theGame.players[0]
            originalDeckCount = theGame.deck.count

            # execute
            theGame.jackpot(theFirstPlayer)

            # test
            expect(theGame.deck.count).to eq originalDeckCount -3
        end

        it "increase the players hand size by 3" do
            # setup
            input_stream = StringIO.new("")
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            theGame = Game.new(numberOfPlayers=3, theTestInterface)
            theGame.deck = StackedDeck.new(theTestInterface) # this ensures that the card played doesn't require input of its own
            theFirstPlayer = theGame.players[0]
            firstPlayersOriginalCardsCount = theFirstPlayer.hand.size

            # execute
            theGame.jackpot(theFirstPlayer)

            # test
            expect(theFirstPlayer.hand.count).to eq firstPlayersOriginalCardsCount +3
        end

        it "should play creepers imidately if they are drawn" do
            # setup
            input_stream = StringIO.new("")
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            theGame = Game.new(numberOfPlayers=3, theTestInterface)
            warCreeper = Creeper.new(1, "War", "with some rules text")
            theGame.deck = StackedDeck.new(theTestInterface, [warCreeper])
            theFirstPlayer = theGame.players[0]
            # assuming the start draw rule is 1

            # execute
            theGame.jackpot(theFirstPlayer)

            # test
            expect(theFirstPlayer.creepers).to include warCreeper
        end

        it "should remove expected number plus the number of creeper cards from deck" do
            # setup
            input_stream = StringIO.new("")
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            theGame = Game.new(numberOfPlayers=3, theTestInterface)
            stackedCreepers = [Creeper.new(1, "War", "with some rules text")]
            theGame.deck = StackedDeck.new(theTestInterface, stackedCreepers)
            theFirstPlayer = theGame.players[0]
            # assuming the start draw rule is 1
            countOfDeckToStart = theGame.deck.count
            jackpotDrawCount = 3

            # execute
            theGame.jackpot(theFirstPlayer)

            # test
            expect(theGame.deck.count).to eq countOfDeckToStart - (jackpotDrawCount + stackedCreepers.size) # the creeper
        end
    end

    describe "draw_2_and_use_em" do
        it "should play all the cards" do
            # setup
            input_stream = StringIO.new("0\n")
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            theGame = Game.new(numberOfPlayers=3, theTestInterface)
            fakeCard1 = FakeCard.new("thing1")
            fakeCard2 = FakeCard.new("thing2")
            cardsToPutOnTop = [fakeCard1, fakeCard2]
            theGame.deck = StackedDeck.new(theTestInterface, cardsToPutOnTop) # this ensures that the card played doesn't require input of its own
            theFirstPlayer = theGame.players[0]

            # execute
            theGame.draw_2_and_use_em(theFirstPlayer)

            # test
            expect(fakeCard1.played).to be true
            expect(fakeCard2.played).to be true
            expect(theTestInterface.cardList.size).to eq 1 # will just play the last card no matter what
        end

        it "should draw 2 cards from the deck" do
            # setup
            input_stream = StringIO.new("0\n")
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            theGame = Game.new(numberOfPlayers=3, theTestInterface)
            theGame.deck = StackedDeck.new(theTestInterface) # this ensures that the card played doesn't require input of its own
            theFirstPlayer = theGame.players[0]
            originalDeckCount = theGame.deck.count

            # execute
            theGame.draw_2_and_use_em(theFirstPlayer)

            # test
            expect(theGame.deck.count).to eq originalDeckCount -2
        end

        it "should play creepers imidately if they are drawn" do
            # setup
            input_stream = StringIO.new("0\n")
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            theGame = Game.new(numberOfPlayers=3, theTestInterface)
            warCreeper = Creeper.new(1, "War", "with some rules text")
            theGame.deck = StackedDeck.new(theTestInterface, [warCreeper])
            theFirstPlayer = theGame.players[0]
            # assuming the start draw rule is 1

            # execute
            theGame.draw_2_and_use_em(theFirstPlayer)

            # test
            expect(theFirstPlayer.creepers).to include warCreeper
        end

        it "should remove expected number plus the number of creeper cards from deck" do
            # setup
            input_stream = StringIO.new("0\n")
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            theGame = Game.new(numberOfPlayers=3, theTestInterface)
            stackedCreepers = [Creeper.new(1, "War", "with some rules text")]
            theGame.deck = StackedDeck.new(theTestInterface, stackedCreepers)
            theFirstPlayer = theGame.players[0]
            # assuming the start draw rule is 1
            countOfDeckToStart = theGame.deck.count
            cardsDrawn = 2

            # execute
            theGame.draw_2_and_use_em(theFirstPlayer)

            # test
            expect(theGame.deck.count).to eq countOfDeckToStart - (cardsDrawn + stackedCreepers.size) # the creeper
        end
    end

    describe "draw_3_play_2_of_them" do
        it "should leave one card remaining and play the others" do
            # setup
            input_stream = StringIO.new("0\n0\n")
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            theGame = Game.new(numberOfPlayers=3, theTestInterface)
            theGame.deck = StackedDeck.new(theTestInterface) # this ensures that the card played doesn't require input of its own
            theFirstPlayer = theGame.players[0]

            # execute
            theGame.draw_3_play_2_of_them(theFirstPlayer)

            # test
            expect(theTestInterface.cardList.size).to eq 1
        end

        it "should draw 3 cards from the deck" do
            # setup
            input_stream = StringIO.new("0\n0\n")
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            theGame = Game.new(numberOfPlayers=3, theTestInterface)
            theGame.deck = StackedDeck.new(theTestInterface) # this ensures that the card played doesn't require input of its own
            theFirstPlayer = theGame.players[0]
            originalDeckCount = theGame.deck.count

            # execute
            theGame.draw_3_play_2_of_them(theFirstPlayer)

            # test
            expect(theGame.deck.count).to eq originalDeckCount -3
        end

        it "should play creepers imidately if they are drawn" do
            # setup
            input_stream = StringIO.new("0\n0\n")
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            theGame = Game.new(numberOfPlayers=3, theTestInterface)
            warCreeper = Creeper.new(1, "War", "with some rules text")
            theGame.deck = StackedDeck.new(theTestInterface, [warCreeper])
            theFirstPlayer = theGame.players[0]
            # assuming the start draw rule is 1

            # execute
            theGame.draw_3_play_2_of_them(theFirstPlayer)

            # test
            expect(theFirstPlayer.creepers).to include warCreeper
        end

        it "should remove expected number plus the number of creeper cards from deck" do
            # setup
            input_stream = StringIO.new("0\n0\n")
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            theGame = Game.new(numberOfPlayers=3, theTestInterface)
            stackedCreepers = [Creeper.new(1, "War", "with some rules text")]
            theGame.deck = StackedDeck.new(theTestInterface, stackedCreepers)
            theFirstPlayer = theGame.players[0]
            # assuming the start draw rule is 1
            countOfDeckToStart = theGame.deck.count
            cardsDrawn = 3

            # execute
            theGame.draw_3_play_2_of_them(theFirstPlayer)

            # test
            expect(theGame.deck.count).to eq countOfDeckToStart - (cardsDrawn + stackedCreepers.size) # the creeper
        end
    end

    describe "discard_and_draw" do
        it "should not include this card when determining how many cards to draw" do
            # setup
            input_stream = StringIO.new("")
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            theGame = Game.new(numberOfPlayers=3, theTestInterface)
            theFirstPlayer = theGame.players[0]
            firstPlayersOriginalCardsCount = theFirstPlayer.hand.size

            # execute
            theGame.discard_and_draw(theFirstPlayer)

            # test
            expect(theFirstPlayer.hand.size).to eq firstPlayersOriginalCardsCount - 1
        end

        it "should play creepers imidately if they are drawn" do
            # setup
            input_stream = StringIO.new("")
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            theGame = Game.new(numberOfPlayers=3, theTestInterface)
            warCreeper = Creeper.new(1, "War", "with some rules text")
            theGame.deck = StackedDeck.new(theTestInterface, [warCreeper])
            theFirstPlayer = theGame.players[0]
            # assuming the start draw rule is 1

            # execute
            theGame.discard_and_draw(theFirstPlayer)

            # test
            expect(theFirstPlayer.creepers).to include warCreeper
        end

        it "should remove expected number plus the number of creeper cards from deck" do
            # setup
            input_stream = StringIO.new("")
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            theGame = Game.new(numberOfPlayers=3, theTestInterface)
            stackedCreepers = [Creeper.new(1, "War", "with some rules text")]
            theGame.deck = StackedDeck.new(theTestInterface, stackedCreepers)
            theFirstPlayer = theGame.players[0]
            # assuming the start draw rule is 1
            countOfDeckToStart = theGame.deck.count
            cardsDrawn = 2

            # execute
            theGame.discard_and_draw(theFirstPlayer)

            # test
            expect(theGame.deck.count).to eq countOfDeckToStart - (cardsDrawn + stackedCreepers.size) # the creeper
        end
    end

    describe "useWhatYouTake" do
        it "should play a card at random from the selected player" do
            # setup
            input_stream = StringIO.new("0\n")
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            numberOfPlayers = 3
            theGame = Game.new(numberOfPlayers=3, theTestInterface)
            theGame.deck = StackedDeck.new(theTestInterface) # this ensures that the card played doesn't require input of its own
            theFirstPlayer = theGame.players[0]
            theSecondPlayer = theGame.players[1]
            theSecondPlayer.hand = [FakeCard.new("thing1"), FakeCard.new("thing2"), FakeCard.new("thing3")]
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
            theGame = Game.new(numberOfPlayers=3, theTestInterface)
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
            theGame = Game.new(numberOfPlayers=3, theTestInterface)
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
            theGame = Game.new(numberOfPlayers=3, theTestInterface)
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
            theGame = Game.new(numberOfPlayers=3, theTestInterface)
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
            theGame = Game.new(numberOfPlayers=3, theTestInterface)
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
            theGame = Game.new(numberOfPlayers=3, theTestInterface)
            theGame.deck = StackedDeck.new(theTestInterface) # this ensures that the card played doesn't require input of its own
            theFirstPlayer = theGame.players[0]
            deckCountBeforeExecution = theGame.deck.count

            # execute
            theGame.todaysSpecial(theFirstPlayer)

            # test
            expect(theFirstPlayer.keepers.size).to eq 3 # stand in for knowing how many cards got played
        end

        it "should play creepers imidately if they are drawn" do
            # setup
            input_stream = StringIO.new("0\nn\nn\n")
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            theGame = Game.new(numberOfPlayers=3, theTestInterface)
            warCreeper = Creeper.new(1, "War", "with some rules text")
            theGame.deck = StackedDeck.new(theTestInterface, [warCreeper])
            theFirstPlayer = theGame.players[0]
            # assuming the start draw rule is 1

            # execute
            theGame.todaysSpecial(theFirstPlayer)

            # test
            expect(theFirstPlayer.creepers).to include warCreeper
        end

        it "should remove expected number plus the number of creeper cards from deck" do
            # setup
            input_stream = StringIO.new("0\nn\nn\n")
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            theGame = Game.new(numberOfPlayers=3, theTestInterface)
            stackedCreepers = [Creeper.new(1, "War", "with some rules text")]
            theGame.deck = StackedDeck.new(theTestInterface, stackedCreepers)
            theFirstPlayer = theGame.players[0]
            # assuming the start draw rule is 1
            countOfDeckToStart = theGame.deck.count
            cardsDrawn = 3

            # execute
            theGame.todaysSpecial(theFirstPlayer)

            # test
            expect(theGame.deck.count).to eq countOfDeckToStart - (cardsDrawn + stackedCreepers.size) # the creeper
        end
    end

    describe "mixItAllUp" do
        it "should maintain the same number of keepers" do
            # setup
            input_stream = StringIO.new("0")
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            theGame = Game.new(numberOfPlayers=3, theTestInterface)
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
            theGame = Game.new(numberOfPlayers=3, theTestInterface)
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

    describe "everybody_gets_1" do
        it "should draw one card per player" do
            # setup
            numberOfPlayers = 4
            input_stream = StringIO.new("0\n" * numberOfPlayers)
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            theGame = Game.new(numberOfPlayers=3, theTestInterface)
            theFirstPlayer = theGame.players[0]
            originalDeckCount = theGame.deck.count

            # execute
            theGame.everybody_gets_1(theFirstPlayer)

            # test
            expect(theGame.deck.count).to eq originalDeckCount-theGame.players.length
        end

        it "each player should have one more card" do
            # setup
            numberOfPlayers = 4
            input_stream = StringIO.new("0\n" * numberOfPlayers)
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            theGame = Game.new(numberOfPlayers=3, theTestInterface)
            theFirstPlayer = theGame.players[0]
            originalDeckCount = theGame.deck.count

            # execute
            theGame.everybody_gets_1(theFirstPlayer)

            # test
            theGame.players.select do |player|
                expect(player.hand.length).to eq 4 # since the opening hand size is 3
            end
        end

        it "should handle if the currentPlayer is set to a number of a player which does not exist" do
            # setup
            numberOfPlayers = 4
            input_stream = StringIO.new("0\n" * numberOfPlayers)
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            theGame = Game.new(numberOfPlayers, theTestInterface)
            theFirstPlayer = theGame.players[0]
            theGame.currentPlayerCounter = 8

            # execute
            theGame.everybody_gets_1(theFirstPlayer)

            # test
            # should just work
        end

        it "should handle if the currentPlayer mod players.length is not 0" do
            # setup
            numberOfPlayers = 4
            input_stream = StringIO.new("0\n" * numberOfPlayers)
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            theGame = Game.new(numberOfPlayers, theTestInterface)
            theFirstPlayer = theGame.players[0]
            theGame.currentPlayerCounter = 9

            # execute
            theGame.everybody_gets_1(theFirstPlayer)

            # test
            # should just work
        end

        it "should play creepers imidately if they are drawn" do
            # setup
            numberOfPlayers = 3
            input_stream = StringIO.new("0\n" * numberOfPlayers)
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            theGame = Game.new(numberOfPlayers, theTestInterface)
            warCreeper = Creeper.new(1, "War", "with some rules text")
            theGame.deck = StackedDeck.new(theTestInterface, [warCreeper])
            theFirstPlayer = theGame.players[0]
            # assuming the start draw rule is 1

            # execute
            theGame.everybody_gets_1(theFirstPlayer)

            # test
            expect(theFirstPlayer.creepers).to include warCreeper
        end

        it "should remove expected number plus the number of creeper cards from deck" do
            # setup
            numberOfPlayers = 3
            input_stream = StringIO.new("0\n" * numberOfPlayers)
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            theGame = Game.new(numberOfPlayers, theTestInterface)
            stackedCreepers = [Creeper.new(1, "War", "with some rules text")]
            theGame.deck = StackedDeck.new(theTestInterface, stackedCreepers)
            theFirstPlayer = theGame.players[0]
            # assuming the start draw rule is 1
            countOfDeckToStart = theGame.deck.count
            cardsDrawn = numberOfPlayers

            # execute
            theGame.everybody_gets_1(theFirstPlayer)

            # test
            expect(theGame.deck.count).to eq countOfDeckToStart - (cardsDrawn + stackedCreepers.size) # the creeper
        end
    end

    describe "tradeHands" do
        it "should not leave the first player with the same hand" do
            # setup
            input_stream = StringIO.new("0") # 0 indexed?
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            theGame = Game.new(numberOfPlayers=3, theTestInterface)
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
            theGame = Game.new(numberOfPlayers=3, theTestInterface)
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
            theGame = Game.new(numberOfPlayers=3, theTestInterface)
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
        it "should handle if the currentPlayer is set to a number of a player which does not exist" do
            # setup
            input_stream = StringIO.new("thing")
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            theGame = Game.new(numberOfPlayers=3, theTestInterface)
            theFirstPlayer = theGame.players[0]
            firstPlayersOriginalCards = theFirstPlayer.hand
            theGame.currentPlayerCounter = 10

            # execute
            theGame.rotateHands(theFirstPlayer)

            # test
            # this should work just fine
        end

        describe "counter clockwise" do
            it "first player should not have the hand they started with" do
                # setup
                input_stream = StringIO.new("thing")
                theTestInterface = TestInterface.new(input_stream, test_outfile)
                theGame = Game.new(numberOfPlayers=3, theTestInterface)
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
                theGame = Game.new(numberOfPlayers=3, theTestInterface)
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
                theGame = Game.new(numberOfPlayers=3, theTestInterface)
                theFirstPlayer = theGame.players[0]
                firstPlayersOriginalCards = theFirstPlayer.hand

                # execute
                theGame.rotateHands(theFirstPlayer)

                # test
                theSecondPlayer = theGame.players[1]
                expect(theSecondPlayer.hand).to eq firstPlayersOriginalCards
            end

            it "should not  let any hands be duplicated" do
                # setup
                input_stream = StringIO.new("thing")
                theTestInterface = TestInterface.new(input_stream, test_outfile)
                theGame = Game.new(numberOfPlayers=3, theTestInterface)
                theFirstPlayer = theGame.players[0]
                firstPlayersOriginalCards = theFirstPlayer.hand
                theGame.currentPlayerCounter = 11

                # execute
                theGame.rotateHands(theFirstPlayer)

                # test
                theGame.players.select do |player|
                    theGame.players.select do |otherPlayer|
                        if player != otherPlayer
                            expect(player.hand).to_not eq otherPlayer.hand
                        end
                    end
                end
            end
        end

        describe "clockwise" do
            it "first player should not have the hand they started with" do
                # setup
                input_stream = StringIO.new("clockwise")
                theTestInterface = TestInterface.new(input_stream, test_outfile)
                theGame = Game.new(numberOfPlayers=3, theTestInterface)
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
                theGame = Game.new(numberOfPlayers=3, theTestInterface)
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
                theGame = Game.new(numberOfPlayers=3, theTestInterface)
                theFirstPlayer = theGame.players[0]
                thePlayerAfterThem = theGame.players[2]
                playerAfterThemsCards = thePlayerAfterThem.hand

                # execute
                theGame.rotateHands(theFirstPlayer)

                # test
                theSecondPlayer = theGame.players[1]
                expect(theSecondPlayer.hand).to eq playerAfterThemsCards
            end

            it "should not  let any hands be duplicated" do
                # setup
                input_stream = StringIO.new("clockwise")
                theTestInterface = TestInterface.new(input_stream, test_outfile)
                theGame = Game.new(numberOfPlayers=3, theTestInterface)
                theFirstPlayer = theGame.players[0]
                firstPlayersOriginalCards = theFirstPlayer.hand
                theGame.currentPlayerCounter = 11

                # execute
                theGame.rotateHands(theFirstPlayer)

                # test
                theGame.players.select do |player|
                    theGame.players.select do |otherPlayer|
                        if player != otherPlayer
                            expect(player.hand).to_not eq otherPlayer.hand
                        end
                    end
                end
            end
        end
    end

    describe "take_another_turn" do
        it "should make sure the current player remains the same when the last card of their turn is played" do
                # setup
                input_stream = StringIO.new("0\n")
                theTestInterface = TestInterface.new(input_stream, test_outfile)
                theGame = Game.new(numberOfPlayers=3, theTestInterface)
                theFirstPlayer = theGame.players[0]
                originalCurrentPlayer = theGame.currentPlayer
                currentPlayerCounter = 0
                # tests this action by having the player use this as their one and
                # only card to play in a turn
                theFirstPlayer.hand.unshift(Action.new(15, "another turn", "some rules text"))

                # execute
                theGame.playCards

                # test
                expect(theGame.currentPlayer).to eq originalCurrentPlayer
        end
    end

    describe "exchange_keepers" do
        it "should not do anything if you have no keepers" do
            # setup
            input_stream = StringIO.new("")
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            theGame = Game.new(numberOfPlayers=3, theTestInterface)
            theFirstPlayer = theGame.players[0]

            # execute
            theGame.exchange_keepers(theFirstPlayer)

            # test
            expect(theTestInterface.prompted).to be nil
        end

        it "should not do anything if you have no keepers" do
            # setup
            input_stream = StringIO.new("")
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            theGame = Game.new(numberOfPlayers=3, theTestInterface)
            theFirstPlayer = theGame.players[0]

            # execute
            theGame.exchange_keepers(theFirstPlayer)

            # test
            # a hacky way to check that there was no prompt
            expect(theTestInterface.prompted).to be nil
        end

        it "should prompt the player if the player and at least one opponent has a keeper" do
            # setup
            input_stream = StringIO.new("1\n")
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            theGame = Game.new(numberOfPlayers=3, theTestInterface)
            theFirstPlayer = theGame.players[0]
            theFirstPlayer.keepers << Keeper.new("thing1")
            theGame.players[1].keepers << Keeper.new("thing2")

            # execute
            theGame.exchange_keepers(theFirstPlayer)

            # test
            expect(theTestInterface.prompted).to_not be nil
        end

        it "should not change the number of keepers either player has" do
            # setup
            input_stream = StringIO.new("1\n0\n0\n")
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            theGame = Game.new(numberOfPlayers=3, theTestInterface)
            theFirstPlayer = theGame.players[0]
            theFirstPlayer.keepers << Keeper.new("thing1")
            firstPlayersOriginalKeeperCount = theFirstPlayer.keepers.size
            theSecondPlayer = theGame.players[1]
            theSecondPlayer.keepers << Keeper.new("thing2")
            secondPlayersOriginalKeeperCount = theSecondPlayer.keepers.size

            # execute
            theGame.exchange_keepers(theFirstPlayer)

            # test
            expect(theFirstPlayer.keepers.size).to eq firstPlayersOriginalKeeperCount
            expect(theSecondPlayer.keepers.size).to eq secondPlayersOriginalKeeperCount
        end

        it "should change which keepers each player has" do
            # setup
            input_stream = StringIO.new("1\n0\n0\n")
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            theGame = Game.new(numberOfPlayers=3, theTestInterface)
            theFirstPlayer = theGame.players[0]
            firstPlayersOriginalKeeper = Keeper.new("thing1")
            theFirstPlayer.keepers << firstPlayersOriginalKeeper
            theSecondPlayer = theGame.players[1]
            secondPLayersOriginalKeeper = Keeper.new("thing2")
            theSecondPlayer.keepers << secondPLayersOriginalKeeper

            # execute
            theGame.exchange_keepers(theFirstPlayer)

            # test
            expect(theFirstPlayer.keepers[0]).to_not eq firstPlayersOriginalKeeper
            expect(theSecondPlayer.keepers[0]).to_not eq secondPLayersOriginalKeeper
        end

        it "should not prompt with any players which have no keepers" do
            # setup
            input_stream = StringIO.new("1\n0\n0\n")
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            theGame = Game.new(numberOfPlayers=3, theTestInterface)
            theFirstPlayer = theGame.players[0]
            firstPlayersOriginalKeeper = Keeper.new("thing1")
            theFirstPlayer.keepers << firstPlayersOriginalKeeper
            theSecondPlayer = theGame.players[1]
            secondPLayersOriginalKeeper = Keeper.new("thing2")
            theSecondPlayer.keepers << secondPLayersOriginalKeeper

            # execute
            theGame.exchange_keepers(theFirstPlayer)

            # test
            expect(theTestInterface.indexed_output).to_not include theGame.players[2].to_s
        end

        it "should not prompt to check if you are sure of your decision" do
            # setup
            input_stream = StringIO.new("0\ny\n")
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            theGame = Game.new(numberOfPlayers=3, theTestInterface)
            theFirstPlayer = theGame.players[0]
            firstPlayersOriginalKeeper = Keeper.new("thing1")
            theFirstPlayer.keepers << firstPlayersOriginalKeeper
            theSecondPlayer = theGame.players[1]
            secondPLayersOriginalKeeper = Keeper.new("thing2")
            theSecondPlayer.keepers << secondPLayersOriginalKeeper

            # execute
            theGame.exchange_keepers(theFirstPlayer)

            # test
            #  This is stand in. if everyone keeps theier starting keepers
            #  then an exchange did not happen
            expect(theFirstPlayer.keepers[0]).to eq firstPlayersOriginalKeeper
            expect(theSecondPlayer.keepers[0]).to eq secondPLayersOriginalKeeper
        end
    end

    describe "resolve_war_rule" do
        it "should ensure that if the player to play it has peace they don't end with it" do
            # setup
            input_stream = StringIO.new("0\n")
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            theGame = Game.new(numberOfPlayers=3, theTestInterface)
            theFirstPlayer = theGame.players[0]
            theFirstPlayer.keepers << Keeper.new("Peace")
            warCreeper = Creeper.new(1, "War", "Some rules text")
            theFirstPlayer.creepers << warCreeper

            # execute
            theGame.resolve_war_rule(theFirstPlayer)

            # test
            expect(theFirstPlayer.creepers).to_not include warCreeper
        end

        it "should give war to selected player" do
            # setup
            input_stream = StringIO.new("0\n")
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            theGame = Game.new(numberOfPlayers=3, theTestInterface)
            theFirstPlayer = theGame.players[0]
            theFirstPlayer.keepers << Keeper.new("Peace")
            warCreeper = Creeper.new(1, "War", "Some rules text")
            theFirstPlayer.creepers << warCreeper

            # execute
            theGame.resolve_war_rule(theFirstPlayer)

            # test
            expect(theGame.players[1].creepers).to include warCreeper
        end
    end

    test_outfile.unlink
end
