require "io/console"
require "tempfile"

require "./constants/prompts.rb"
require "./game.rb"

describe "game" do

    test_outfile = Tempfile.new 'test_output'

    it "should construct" do
        test_logger = Logger.new(test_outfile)
        theGame = Game.new(test_logger)
    end

    describe "drawCards" do
        it "should draw bassed on the 'drawRule' if the count parmeter is :draw_rule" do
            # setup
            input_stream = StringIO.new("")
            test_logger = Logger.new(test_outfile)
            test_interface = TestInterface.new(input_stream, test_outfile)
            theGame = Game.new(test_logger, test_interface, players=[], StackedDeck.new(test_logger))
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
            test_logger = Logger.new(test_outfile)
            testInterface = TestInterface.new(input_stream, test_outfile)
            players = Player.generate_players(3)
            stacked_deck = StackedDeck.new(test_logger, [Creeper.new(10000, "Screem", "Some very scary rule text")])
            theGame = Game.new(test_logger, testInterface, players, stacked_deck)
            theFirstPlayer = theGame.players[0]

            # execute
            returnedCards = theGame.drawCards(theFirstPlayer, :draw_rule)

            # test
            expect(returnedCards.length).to eq theGame.ruleBase.drawRule
        end

        it "should never return any creepers" do
            # setup
            input_stream = StringIO.new("")
            test_logger = Logger.new(test_outfile)
            testInterface = TestInterface.new(input_stream, test_outfile)
            players = Player.generate_players(3)
            stacked_deck = StackedDeck.new(test_logger,
                [Creeper.new(10000, "Screem", "Some very scary rule text"),
                Creeper.new(10001, "Lonelyness", "There is no one there"),
                Creeper.new(10002, "Depression", "There is no one there"),
                Creeper.new(10003, "Bankrupsy", "There is no one there"),
                Creeper.new(10004, "Lust", "There is no one there"),
                Creeper.new(10005, "Loss", "There is no one there")])
            theGame = Game.new(test_logger, testInterface, players, stacked_deck)
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
            testLogger = Logger.new(test_outfile)
            testInterface = TestInterface.new(input_stream, test_outfile)
            players = Player.generate_players(3)
            stacked_deck = StackedDeck.new(testLogger,
                [Creeper.new(10000, "Screem", "Some very scary rule text"),
                Creeper.new(10001, "Lonelyness", "There is no one there")])
            theGame = Game.new(testLogger, testInterface, players, stacked_deck)
            theFirstPlayer = theGame.players[0]

            # execute
            returnedCards = theGame.drawCards(theFirstPlayer, :draw_rule)

            # test
            expect(returnedCards.length).to eq theGame.ruleBase.drawRule
        end

        it "should draw as many cards as it can from the deck and stop when there are no more" do
            # setup
            input_stream = StringIO.new("")
            test_logger = Logger.new(test_outfile)
            testInterface = TestInterface.new(input_stream, test_outfile)
            players = Player.generate_players(3)
            theWholeDeck = [Keeper.new(10000, "wall art"),
                    Keeper.new(10001, "new car smell")]
            stacked_deck = StackedDeck.new(test_logger,
                theWholeDeck,
                startempty=true)
            theGame = Game.new(test_logger, testInterface, players, stacked_deck)
            thefirstplayer = theGame.players[0]

            # execute
            returnedcards = theGame.drawCards(thefirstplayer, 3)

            # test
            expect(returnedcards.length).to eq theWholeDeck.size # since that is all the cards there is to draw
        end

        it "should stop trying to draw if there are no more cards to draw" do
            # setup
            input_stream = StringIO.new("")
            test_logger = Logger.new(test_outfile)
            testInterface = TestInterface.new(input_stream, test_outfile)
            players = Player.generate_players(3)
            stacked_deck = StackedDeck.new(test_logger,
                [Creeper.new(10000, "screem", "some very scary rule text"),
                    Creeper.new(10001, "lonelyness", "there is no one there")],
                startempty=true)
            theGame = Game.new(test_logger, testInterface, players, stacked_deck)
            thefirstplayer = theGame.players[0]

            # execute
            returnedcards = theGame.drawCards(thefirstplayer, :draw_rule)

            # test
            expect(returnedcards.length).to eq 0 # 0 since there are no "real cards to draw"
        end
    end

    describe "removeDownToKeeperLimit" do
        it "should make sure that the player has no more keepers than the current keeper limit" do
            # setup
            input_stream = StringIO.new("0\n")
            testLogger = Logger.new(test_outfile)
            testInterface = TestInterface.new(input_stream, test_outfile, Constants::PROMPT_STRINGS)
            players = Player.generate_players(3)
            theGame = Game.new(testLogger, testInterface, players)
            theFirstPlayer = theGame.players[0]
            theFirstPlayer.add_permanent(Keeper.new(0, "thing1"))
            theFirstPlayer.add_permanent(Keeper.new(0, "thing2"))
            theFirstPlayer.add_permanent(Keeper.new(0, "thing3"))
            keeperLimit = 2
            theGame.ruleBase.addRule(Limit.new("keeper limit 2", 4, "some dumb rules text", keeperLimit))

            # execute
            theGame.removeDownToKeeperLimit(theFirstPlayer)

            # test
            expect(theFirstPlayer.keepers.size).to eq keeperLimit
        end
    end

    describe "discardDownToLimit" do
        it "should make sure that the player has no more cards in hand than the current hand limit" do
            # setup
            input_stream = StringIO.new("0\n")
            testLogger = Logger.new(test_outfile)
            players = Player.generate_players(3)
            player_prompts = PlayerPromptGenerator.generate_prompts(players, Constants::USER_SPECIFIC_PROMPTS)
            testInterface = TestInterface.new(input_stream, test_outfile, Constants::PROMPT_STRINGS.merge(player_prompts))
            theGame = Game.new(testLogger, testInterface, players)
            theGame.setup
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
            testLogger = Logger.new(test_outfile)
            testInterface = TestInterface.new(input_stream, test_outfile)
            players = Player.generate_players(3)
            theGame = Game.new(testLogger, testInterface, players)
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
            testLogger = Logger.new(test_outfile)
            testInterface = TestInterface.new(input_stream, test_outfile)
            players = Player.generate_players(3)
            theGame = Game.new(testLogger, testInterface, players)
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
            testLogger = Logger.new(test_outfile)
            testInterface = TestInterface.new(input_stream, test_outfile)
            players = Player.generate_players(3)
            stacked_deck = StackedDeck.new(testLogger, cardsToPutOnTop=[], startEmpty= false, withCreepers=false)
            theGame = Game.new(testLogger, testInterface, players, stacked_deck)
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
            testLogger = Logger.new(test_outfile)
            testInterface = TestInterface.new(input_stream, test_outfile)
            players = Player.generate_players(3)
            warCreeper = Creeper.new(1, "War", "with some rules text")
            stacked_deck = StackedDeck.new(testLogger, [warCreeper])
            theGame = Game.new(testLogger, testInterface, players, stacked_deck)
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
            testLogger = Logger.new(test_outfile)
            testInterface = TestInterface.new(input_stream, test_outfile)
            players = Player.generate_players(3)
            warCreeper = Creeper.new(1, "War", "with some rules text")
            stacked_deck = StackedDeck.new(testLogger, [warCreeper])
            theGame = Game.new(testLogger, testInterface, players, stacked_deck)
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
            testLogger = Logger.new(test_outfile)
            theGame = Game.new(testLogger)

            # execute , test
            expect(theGame.winner).to be false
        end
    end

    describe "has_player_won" do
        it "should return false if the game has no goal" do
            # setup
            input_stream = StringIO.new("")
            testLogger = Logger.new(test_outfile)
            testInterface = TestInterface.new(input_stream, test_outfile)
            players = Player.generate_players(3)
            theGame = Game.new(testLogger, testInterface, players)
            theFirstPlayer = theGame.players[0]
            # asume that a new game has no goal

            # execute, test
            expect(theGame.has_player_won?(theFirstPlayer)).to be false
        end

        it "should return true if the goal has been met" do
            # setup
            input_stream = StringIO.new("")
            testLogger = Logger.new(test_outfile)
            testInterface = TestInterface.new(input_stream, test_outfile)
            players = Player.generate_players(3)
            aStackedDeck = StackedDeck.new(testLogger, cardsToPutOnTop=[], startEmpty=false, withCreepers=false)
            theGame = Game.new(testLogger, testInterface, players, aStackedDeck)
            keeper1 = Keeper.new(1, "thing1")
            keeper2 = Keeper.new(2, "thing2")
            theGame.setGoal(Goal.new("do a thing", [keeper1, keeper2], "some rule text"))
            theFirstPlayer = theGame.players[0]
            theFirstPlayer.keepers << keeper1
            theFirstPlayer.keepers << keeper2

            # execute, test
            expect(theGame.has_player_won?(theFirstPlayer)).to be true
        end

        it "should return false if the goal has been met but the player has any creepers" do
            # setup
            input_stream = StringIO.new("")
            testLogger = Logger.new(test_outfile)
            testInterface = TestInterface.new(input_stream, test_outfile)
            players = Player.generate_players(3)
            theGame = Game.new(testLogger, testInterface, players)
            keeper1 = Keeper.new(1, "thing1")
            keeper2 = Keeper.new(2, "thing2")
            theGame.setGoal(Goal.new("do a thing", [keeper1, keeper2], "some rule text"))
            theFirstPlayer = theGame.players[0]
            theFirstPlayer.keepers << keeper1
            theFirstPlayer.keepers << keeper2
            theFirstPlayer.add_creeper(Creeper.new(1, "pure evil", "some evil rule thing"))

            # execute, test
            expect(theGame.has_player_won?(theFirstPlayer)).to be false
        end
    end


    describe "opponents" do
        it "should only get the opponents of the player that is passed in" do
            # setup
            input_stream = StringIO.new("")
            testLogger = Logger.new(test_outfile)
            testInterface = TestInterface.new(input_stream, test_outfile)
            players = Player.generate_players(3)
            theGame = Game.new(testLogger, testInterface, players)
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
            testLogger = Logger.new(test_outfile)
            testInterface = TestInterface.new(input_stream, test_outfile)
            players = Player.generate_players(3)
            stacked_deck = StackedDeck.new(testLogger) # this ensures that the card played doesn't require input of its own
            theGame = Game.new(testLogger, testInterface, players, stacked_deck)
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
            testLogger = Logger.new(test_outfile)
            testInterface = TestInterface.new(input_stream, test_outfile)
            players = Player.generate_players(3)
            stacked_deck = StackedDeck.new(testLogger) # this ensures that the card played doesn't require input of its own
            theGame = Game.new(testLogger, testInterface, players, stacked_deck)
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
            testLogger = Logger.new(test_outfile)
            testInterface = TestInterface.new(input_stream, test_outfile)
            players = Player.generate_players(3)
            warCreeper = Creeper.new(1, "War", "with some rules text")
            stacked_deck = StackedDeck.new(testLogger, [warCreeper])
            theGame = Game.new(testLogger, testInterface, players, stacked_deck)
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
            testLogger = Logger.new(test_outfile)
            testInterface = TestInterface.new(input_stream, test_outfile)
            players = Player.generate_players(3)
            stackedCreepers = [Creeper.new(1, "War", "with some rules text")]
            stacked_deck = StackedDeck.new(testLogger, stackedCreepers)
            theGame = Game.new(testLogger, testInterface, players, stacked_deck)
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
            testLogger = Logger.new(test_outfile)
            testInterface = TestInterface.new(input_stream, test_outfile, Constants::PROMPT_STRINGS)
            players = Player.generate_players(3)
            fakeCard1 = FakeCard.new("thing1")
            fakeCard2 = FakeCard.new("thing2")
            cardsToPutOnTop = [fakeCard1, fakeCard2]
            stacked_deck = StackedDeck.new(testLogger, cardsToPutOnTop) # this ensures that the card played doesn't require input of its own
            theGame = Game.new(testLogger, testInterface, players, stacked_deck)
            theFirstPlayer = theGame.players[0]

            # execute
            theGame.draw_2_and_use_em(theFirstPlayer)

            # test
            expect(fakeCard1.played).to be true
            expect(fakeCard2.played).to be true
            expect(testInterface.card_list.size).to eq 1 # will just play the last card no matter what
        end

        it "should draw 2 cards from the deck" do
            # setup
            input_stream = StringIO.new("0\n")
            testLogger = Logger.new(test_outfile)
            testInterface = TestInterface.new(input_stream, test_outfile, Constants::PROMPT_STRINGS)
            players = Player.generate_players(3)
            stacked_deck = StackedDeck.new(testLogger) # this ensures that the card played doesn't require input of its own
            theGame = Game.new(testLogger, testInterface, players, stacked_deck)
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
            testLogger = Logger.new(test_outfile)
            testInterface = TestInterface.new(input_stream, test_outfile, Constants::PROMPT_STRINGS)
            players = Player.generate_players(3)
            warCreeper = Creeper.new(1, "War", "with some rules text")
            stacked_deck = StackedDeck.new(testLogger, [warCreeper])
            theGame = Game.new(testLogger, testInterface, players, stacked_deck)
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
            testLogger = Logger.new(test_outfile)
            testInterface = TestInterface.new(input_stream, test_outfile, Constants::PROMPT_STRINGS)
            players = Player.generate_players(3)
            stackedCreepers = [Creeper.new(1, "War", "with some rules text")]
            stacked_deck = StackedDeck.new(testLogger, stackedCreepers)
            theGame = Game.new(testLogger, testInterface, players, stacked_deck)
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
            testLogger = Logger.new(test_outfile)
            testInterface = TestInterface.new(input_stream, test_outfile, Constants::PROMPT_STRINGS)
            players = Player.generate_players(3)
            stacked_deck = StackedDeck.new(testLogger) # this ensures that the card played doesn't require input of its own
            theGame = Game.new(testLogger, testInterface, players, stacked_deck)
            theFirstPlayer = theGame.players[0]

            # execute
            theGame.draw_3_play_2_of_them(theFirstPlayer)

            # test
            expect(testInterface.card_list.size).to eq 1
        end

        it "should draw 3 cards from the deck" do
            # setup
            input_stream = StringIO.new("0\n0\n")
            testLogger = Logger.new(test_outfile)
            testInterface = TestInterface.new(input_stream, test_outfile, Constants::PROMPT_STRINGS)
            players = Player.generate_players(3)
            stacked_deck = StackedDeck.new(testLogger) # this ensures that the card played doesn't require input of its own
            theGame = Game.new(testLogger, testInterface, players, stacked_deck)
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
            testLogger = Logger.new(test_outfile)
            testInterface = TestInterface.new(input_stream, test_outfile, Constants::PROMPT_STRINGS)
            players = Player.generate_players(3)
            warCreeper = Creeper.new(1, "War", "with some rules text")
            stacked_deck = StackedDeck.new(testLogger, [warCreeper])
            theGame = Game.new(testLogger, testInterface, players, stacked_deck)
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
            testLogger = Logger.new(test_outfile)
            testInterface = TestInterface.new(input_stream, test_outfile, Constants::PROMPT_STRINGS)
            players = Player.generate_players(3)
            stackedCreepers = [Creeper.new(1, "War", "with some rules text")]
            stacked_deck = StackedDeck.new(testLogger, stackedCreepers)
            theGame = Game.new(testLogger, testInterface, players, stacked_deck)
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
            testLogger = Logger.new(test_outfile)
            testInterface = TestInterface.new(input_stream, test_outfile)
            players = Player.generate_players(3)
            theGame = Game.new(testLogger, testInterface, players)
            theFirstPlayer = theGame.players[0]
            firstPlayersOriginalCardsCount = theFirstPlayer.hand.size

            # execute
            theGame.discard_and_draw(theFirstPlayer)

            # test
            expect(theFirstPlayer.hand.size).to eq firstPlayersOriginalCardsCount
        end

        it "should play creepers imidately if they are drawn" do
            # setup
            input_stream = StringIO.new("")
            testLogger = Logger.new(test_outfile)
            testInterface = TestInterface.new(input_stream, test_outfile)
            players = Player.generate_players(3)
            warCreeper = Creeper.new(1, "War", "with some rules text")
            stacked_deck = StackedDeck.new(testLogger, [warCreeper])
            theGame = Game.new(testLogger, testInterface, players, stacked_deck)
            theGame.setup
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
            testLogger = Logger.new(test_outfile)
            testInterface = TestInterface.new(input_stream, test_outfile)
            players = Player.generate_players(3)
            theGame = Game.new(testLogger, testInterface, players)
            theGame.setup
            stackedCreepers = [Creeper.new(1, "War", "with some rules text")]
            theGame.deck = StackedDeck.new(testLogger, stackedCreepers)
            theFirstPlayer = theGame.players[0]
            # assuming the start draw rule is 1
            countOfDeckToStart = theGame.deck.count
            cardsDrawn = 3

            # execute
            theGame.discard_and_draw(theFirstPlayer)

            # test
            expect(theGame.deck.count).to eq countOfDeckToStart - (cardsDrawn + stackedCreepers.size) # the creeper
        end
    end

    describe "use_what_you_take" do
        it "should play a card at random from the selected player" do
            # setup
            input_stream = StringIO.new("0\n")
            testLogger = Logger.new(test_outfile)
            testInterface = TestInterface.new(input_stream, test_outfile, Constants::PROMPT_STRINGS)
            players = Player.generate_players(3)
            stacked_deck = StackedDeck.new(testLogger) # this ensures that the card played doesn't require input of its own
            theGame = Game.new(testLogger, testInterface, players, stacked_deck)
            theFirstPlayer = theGame.players[0]
            theSecondPlayer = theGame.players[1]
            theSecondPlayer.set_hand([FakeCard.new("thing1"), FakeCard.new("thing2"), FakeCard.new("thing3")])
            secondPlayersOriginalCardsCount = theSecondPlayer.hand.size

            # execute
            theGame.use_what_you_take(theFirstPlayer)

            # test
            expect(theSecondPlayer.hand.size).to eq secondPlayersOriginalCardsCount - 1 # a stand in to make sure the right number of cards got played
        end

        it "should not play any cards if no other player has a hand" do
            # setup
            input_stream = StringIO.new("")
            testLogger = Logger.new(test_outfile)
            testInterface = TestInterface.new(input_stream, test_outfile)
            numberOfPlayers = 2
            players = Player.generate_players(numberOfPlayers)
            stacked_deck = StackedDeck.new(testLogger)
            theGame = Game.new(testLogger, testInterface, players, stacked_deck)
            theFirstPlayer = theGame.players[0]
            theSecondPlayer = theGame.players[1]
            theSecondPlayer.set_hand([])

            # execute
            theGame.use_what_you_take(theFirstPlayer)

            # test
            # should not crash
        end
    end

    describe "taxation" do
        it "the first player should get some number of cards 1 less than the number of the players in game when the game is new" do
            # setup
            input_stream = StringIO.new("0\n0\n0\n")
            testLogger = Logger.new(test_outfile)
            numberOfPlayers = 3
            players = Player.generate_players(numberOfPlayers)
            player_prompts = PlayerPromptGenerator.generate_prompts(players, Constants::USER_SPECIFIC_PROMPTS)
            testInterface = TestInterface.new(input_stream, test_outfile, player_prompts)
            theGame = Game.new(testLogger, testInterface, players)
            theGame.setup
            theFirstPlayer = theGame.players[0]
            firstPlayersOriginalCards = theFirstPlayer.hand

            # execute
            theGame.taxation(theFirstPlayer)

            # test
            expect(theFirstPlayer.hand.size).to eq firstPlayersOriginalCards.size + (numberOfPlayers-1)
        end

        it "the second and third players should be down 1 card when the game is setup" do
            # setup
            input_stream = StringIO.new("0\n0\n0\n")
            testLogger = Logger.new(test_outfile)
            numberOfPlayers = 3
            players = Player.generate_players(numberOfPlayers)
            player_prompts = PlayerPromptGenerator.generate_prompts(players, Constants::USER_SPECIFIC_PROMPTS)
            testInterface = TestInterface.new(input_stream, test_outfile, player_prompts)
            theGame = Game.new(testLogger, testInterface, players)
            theGame.setup
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

        it "should skip players who have no cards" do
            # setup
            input_stream = StringIO.new("0\n0\n0\n")
            testLogger = Logger.new(test_outfile)
            numberOfPlayers = 2
            testInterface = TestInterface.new(input_stream, test_outfile, {prompt: "some prompt"})
            player_doubles = [double("player1", hand: [FakeCard.new("make believe")], give_card_to_player_prompt_name: :prompt, add_cards_to_hand: nil)]
            player_doubles << double("player2", hand: [], add_cards_to_hand: nil)
            theGame = Game.new(testLogger, testInterface, player_doubles)
            theFirstPlayer = theGame.players[0]

            # execute
            theGame.taxation(theFirstPlayer)

            # test
            expect(testInterface.prompted).not_to be true
        end

    end

    describe "todaysSpecial" do
        it "should draw 3 cards" do
            # setup
            input_stream = StringIO.new("0\nn\nn\n")
            testLogger = Logger.new(test_outfile)
            testInterface = TestInterface.new(input_stream, test_outfile, Constants::PROMPT_STRINGS)
            numberOfPlayers = 3
            players = Player.generate_players(numberOfPlayers)
            stacked_deck = StackedDeck.new(testLogger) # this ensures that the card played doesn't require input of its own
            theGame = Game.new(testLogger, testInterface, players, stacked_deck)
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
            testLogger = Logger.new(test_outfile)
            testInterface = TestInterface.new(input_stream, test_outfile, Constants::PROMPT_STRINGS)
            numberOfPlayers = 3
            players = Player.generate_players(numberOfPlayers)
            stacked_deck = StackedDeck.new(testLogger) # this ensures that the card played doesn't require input of its own
            theGame = Game.new(testLogger, testInterface, players, stacked_deck)
            theFirstPlayer = theGame.players[0]
            deckCountBeforeExecution = theGame.deck.count

            # execute
            theGame.todaysSpecial(theFirstPlayer)

            # test
            expect(theFirstPlayer.keepers.size).to eq 1 # stand in for knowing how many cards got played
        end

        it "should only play two cards if it is not your birthday but is a holiday" do
            # setup
            input_stream = StringIO.new("0\nn\ny\n0\n")
            testLogger = Logger.new(test_outfile)
            testInterface = TestInterface.new(input_stream, test_outfile, Constants::PROMPT_STRINGS)
            numberOfPlayers = 3
            players = Player.generate_players(numberOfPlayers)
            stacked_deck = StackedDeck.new(testLogger) # this ensures that the card played doesn't require input of its own
            theGame = Game.new(testLogger, testInterface, players, stacked_deck)
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
            testLogger = Logger.new(test_outfile)
            testInterface = TestInterface.new(input_stream, test_outfile, Constants::PROMPT_STRINGS)
            numberOfPlayers = 3
            players = Player.generate_players(numberOfPlayers)
            stacked_deck = StackedDeck.new(testLogger) # this ensures that the card played doesn't require input of its own
            theGame = Game.new(testLogger, testInterface, players, stacked_deck)
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
            testLogger = Logger.new(test_outfile)
            testInterface = TestInterface.new(input_stream, test_outfile, Constants::PROMPT_STRINGS)
            numberOfPlayers = 3
            players = Player.generate_players(numberOfPlayers)
            warCreeper = Creeper.new(1, "War", "with some rules text")
            stacked_deck = StackedDeck.new(testLogger, [warCreeper])
            theGame = Game.new(testLogger, testInterface, players, stacked_deck)
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
            testLogger = Logger.new(test_outfile)
            testInterface = TestInterface.new(input_stream, test_outfile, Constants::PROMPT_STRINGS)
            numberOfPlayers = 3
            players = Player.generate_players(numberOfPlayers)
            stackedCreepers = [Creeper.new(1, "War", "with some rules text")]
            stacked_deck = StackedDeck.new(testLogger, stackedCreepers)
            theGame = Game.new(testLogger, testInterface, players, stacked_deck)
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

    describe "mix_it_all_up" do
        it "should maintain the same number of keepers" do
            # setup
            input_stream = StringIO.new("0")
            testLogger = Logger.new(test_outfile)
            testInterface = TestInterface.new(input_stream, test_outfile)
            numberOfPlayers = 3
            players = Player.generate_players(numberOfPlayers)
            theGame = Game.new(testLogger, testInterface, players)
            theFirstPlayer = theGame.players[0]
            keeper1 = Keeper.new(0, "Thing1")
            keeper2 = Keeper.new(0, "thing2")
            theGame.players[0].keepers << keeper1
            theGame.players[1].keepers << keeper2
            allBeginningKeepers = theGame.players.flat_map do |player|
                player.keepers
            end

            # execute
            theGame.mix_it_all_up(theFirstPlayer)

            # test
            allEndingKeepers = theGame.players.flat_map do |player|
                player.keepers
            end
            expect(allEndingKeepers.size).to eq allBeginningKeepers.size
        end

        it "should randomly move creepers as well" do
            # setup
            input_stream = StringIO.new("0")
            testLogger = Logger.new(test_outfile)
            testInterface = TestInterface.new(input_stream, test_outfile)
            numberOfPlayers = 1000
            players = Player.generate_players(numberOfPlayers)
            theGame = Game.new(testLogger, testInterface, players)
            theFirstPlayer = theGame.players[0]
            keeper1 = Keeper.new(0, "Thing1")
            keeper2 = Keeper.new(0, "thing2")
            theGame.players[0].keepers << keeper1
            theGame.players[1].keepers << keeper2
            theGame.players[100].add_creeper(Creeper.new(1, "the devil", "scary rules text"))

            # execute
            theGame.mix_it_all_up(theFirstPlayer)

            # test
            expect(theGame.players[100].creepers.any?).to be false
        end

        it "should resolve the war rule so that no person ends up with peace and war" do
            # setup
            input_stream = StringIO.new("0")
            testLogger = Logger.new(test_outfile)
            random = Object.new
            random.define_singleton_method(:rand) do |num|
                0
            end
            numberOfPlayers = 2
            players = Player.generate_players(numberOfPlayers)
            player_prompts = PlayerPromptGenerator.generate_prompts(players, Constants::USER_SPECIFIC_PROMPTS)
            testInterface = TestInterface.new(input_stream, test_outfile, player_prompts)
            theGame = Game.new(testLogger, testInterface, players, StackedDeck.new(testLogger), random)
            theFirstPlayer = theGame.players[0]
            keeper1 = Keeper.new(0, "Thing1")
            warCreeper = Creeper.new(1, "I am WAR", "some rules text")
            peaceKeeper = Keeper.new(16, "I am peace")
            theGame.players[0].keepers << peaceKeeper
            theGame.players[0].keepers << keeper1
            theGame.players[1].add_creeper(warCreeper)

            # execute
            theGame.mix_it_all_up(theFirstPlayer)

            # test
            expect(theGame.players[0].creepers).to_not include warCreeper
        end
    end

    describe "letsDoThatAgain" do
        it "should non contain any keepers or goals" do
            # setup
            input_stream = StringIO.new("0")
            testLogger = Logger.new(test_outfile)
            testInterface = TestInterface.new(input_stream, test_outfile, Constants::PROMPT_STRINGS)
            numberOfPlayers = 3
            players = Player.generate_players(numberOfPlayers)
            theGame = Game.new(testLogger, testInterface, players)
            theFirstPlayer = theGame.players[0]
            theGame.discardPile << Action.new(3, "jackpot2", "here are some rules")
            theGame.discardPile << Rule.new("some draw rule", 1, "Draw 9 cards")
            keeper1 = Keeper.new(0, "Thing1")
            keeper2 = Keeper.new(0, "thing2")
            theGame.discardPile << keeper1
            theGame.discardPile << keeper2
            theGame.discardPile << Goal.new("Achive me", [keeper1, keeper2] , "You most have these cards to win")

            # execute
            theGame.letsDoThatAgain(theFirstPlayer)

            # test
            testInterface.card_list.select do |card|
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
            testLogger = Logger.new(test_outfile)
            players = Player.generate_players(numberOfPlayers)
            player_prompts = PlayerPromptGenerator.generate_prompts(players, Constants::USER_SPECIFIC_PROMPTS)
            testInterface = TestInterface.new(input_stream, test_outfile, player_prompts)
            stacked_deck = StackedDeck.new(testLogger, cardsToPutOnTop=[], startEmpty=false, withCreepers=false)
            theGame = Game.new(testLogger, testInterface, players, stacked_deck)
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
            testLogger = Logger.new(test_outfile)
            players = Player.generate_players(numberOfPlayers)
            player_prompts = PlayerPromptGenerator.generate_prompts(players, Constants::USER_SPECIFIC_PROMPTS)
            testInterface = TestInterface.new(input_stream, test_outfile, Constants::PROMPT_STRINGS.merge(player_prompts))
            theGame = Game.new(testLogger, testInterface, players)
            theFirstPlayer = theGame.players[0]
            originalDeckCount = theGame.deck.count

            # execute
            theGame.everybody_gets_1(theFirstPlayer)

            # test
            theGame.players.select do |player|
                expect(player.hand.length).to eq 1 # since no hands
            end
        end

        it "should handle if the currentPlayer is set to a number of a player which does not exist" do
            # setup
            numberOfPlayers = 4
            input_stream = StringIO.new("0\n" * numberOfPlayers)
            testLogger = Logger.new(test_outfile)
            players = Player.generate_players(numberOfPlayers)
            player_prompts = PlayerPromptGenerator.generate_prompts(players, Constants::USER_SPECIFIC_PROMPTS)
            testInterface = TestInterface.new(input_stream, test_outfile, player_prompts)
            theGame = Game.new(testLogger, testInterface, players)
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
            testLogger = Logger.new(test_outfile)
            players = Player.generate_players(numberOfPlayers)
            player_prompts = PlayerPromptGenerator.generate_prompts(players, Constants::USER_SPECIFIC_PROMPTS)
            testInterface = TestInterface.new(input_stream, test_outfile, player_prompts)
            theGame = Game.new(testLogger, testInterface, players)
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
            testLogger = Logger.new(test_outfile)
            players = Player.generate_players(numberOfPlayers)
            player_prompts = PlayerPromptGenerator.generate_prompts(players, Constants::USER_SPECIFIC_PROMPTS)
            testInterface = TestInterface.new(input_stream, test_outfile, player_prompts)
            warCreeper = Creeper.new(1, "War", "with some rules text")
            stacked_deck = StackedDeck.new(testLogger, [warCreeper])
            theGame = Game.new(testLogger, testInterface, players, stacked_deck)
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
            testLogger = Logger.new(test_outfile)
            players = Player.generate_players(numberOfPlayers)
            player_prompts = PlayerPromptGenerator.generate_prompts(players, Constants::USER_SPECIFIC_PROMPTS)
            testInterface = TestInterface.new(input_stream, test_outfile, player_prompts)
            stackedCreepers = [Creeper.new(1, "War", "with some rules text")]
            stacked_deck = StackedDeck.new(testLogger, stackedCreepers)
            theGame = Game.new(testLogger, testInterface, players, stacked_deck)
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
            testLogger = Logger.new(test_outfile)
            testInterface = TestInterface.new(input_stream, test_outfile, Constants::PROMPT_STRINGS)
            numberOfPlayers = 3
            players = Player.generate_players(numberOfPlayers)
            theGame = Game.new(testLogger, testInterface, players)
            theGame.setup
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
            testLogger = Logger.new(test_outfile)
            testInterface = TestInterface.new(input_stream, test_outfile, Constants::PROMPT_STRINGS)
            numberOfPlayers = 3
            players = Player.generate_players(numberOfPlayers)
            theGame = Game.new(testLogger, testInterface, players)
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
            testLogger = Logger.new(test_outfile)
            testInterface = TestInterface.new(input_stream, test_outfile, Constants::PROMPT_STRINGS)
            numberOfPlayers = 3
            players = Player.generate_players(numberOfPlayers)
            theGame = Game.new(testLogger, testInterface, players)
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
            testLogger = Logger.new(test_outfile)
            testInterface = TestInterface.new(input_stream, test_outfile)
            numberOfPlayers = 3
            players = Player.generate_players(numberOfPlayers)
            theGame = Game.new(testLogger, testInterface, players)
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
                testLogger = Logger.new(test_outfile)
                testInterface = TestInterface.new(input_stream, test_outfile)
                numberOfPlayers = 3
                players = Player.generate_players(numberOfPlayers)
                theGame = Game.new(testLogger, testInterface, players)
                theGame.setup
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
                testLogger = Logger.new(test_outfile)
                testInterface = TestInterface.new(input_stream, test_outfile)
                numberOfPlayers = 3
                players = Player.generate_players(numberOfPlayers)
                theGame = Game.new(testLogger, testInterface, players)
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
                testLogger = Logger.new(test_outfile)
                testInterface = TestInterface.new(input_stream, test_outfile)
                numberOfPlayers = 3
                players = Player.generate_players(numberOfPlayers)
                theGame = Game.new(testLogger, testInterface, players)
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
                testLogger = Logger.new(test_outfile)
                testInterface = TestInterface.new(input_stream, test_outfile)
                numberOfPlayers = 3
                players = Player.generate_players(numberOfPlayers)
                theGame = Game.new(testLogger, testInterface, players)
                theGame.setup
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
                testLogger = Logger.new(test_outfile)
                testInterface = TestInterface.new(input_stream, test_outfile)
                numberOfPlayers = 3
                players = Player.generate_players(numberOfPlayers)
                theGame = Game.new(testLogger, testInterface, players)
                theGame.setup
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
                testLogger = Logger.new(test_outfile)
                testInterface = TestInterface.new(input_stream, test_outfile)
                numberOfPlayers = 3
                players = Player.generate_players(numberOfPlayers)
                theGame = Game.new(testLogger, testInterface, players)
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
                testLogger = Logger.new(test_outfile)
                testInterface = TestInterface.new(input_stream, test_outfile)
                numberOfPlayers = 3
                players = Player.generate_players(numberOfPlayers)
                theGame = Game.new(testLogger, testInterface, players)
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
                testLogger = Logger.new(test_outfile)
                testInterface = TestInterface.new(input_stream, test_outfile)
                numberOfPlayers = 3
                players = Player.generate_players(numberOfPlayers)
                theGame = Game.new(testLogger, testInterface, players)
                theGame.setup
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
            pending("This has been thuroughly broken and needs to be fixed")
            # setup
            input_stream = StringIO.new("0\n")
            testLogger = Logger.new(test_outfile)
            theGame = Game.new(testLogger)
            theFirstPlayer = theGame.players[0]
            originalCurrentPlayer = theGame.currentPlayer
            currentPlayerCounter = 0
            # tests this action by having the player use this as their one and
            # only card to play in a turn
            theFirstPlayer.hand.unshift(Action.new(15, "another turn", "some rules text"))

            # execute
            theGame.playCards(theFirstPlayer)

            # test
            expect(theGame.currentPlayer).to eq originalCurrentPlayer
        end

        it "should make sure the current player remains the same when they play a card in the middle of their turn" do
            pending("This has been thuroughly broken and needs to be fixed")
            # setup
            input_stream = StringIO.new("0\n0\n")
            testLogger = Logger.new(test_outfile)
            theGame = Game.new(testLogger)
            theGame.ruleBase.addRule(Rule.new("play more", 2, "play 2"))
            theFirstPlayer = theGame.players[0]
            originalCurrentPlayer = theGame.currentPlayer
            currentPlayerCounter = 0
            theFirstPlayer.hand.unshift(Keeper.new(15, "Any ol thing "))
            theFirstPlayer.hand.unshift(Action.new(15, "another turn", "some rules text"))

            # execute
            theGame.playCards(theFirstPlayer)

            # test
            expect(theGame.currentPlayer).to eq originalCurrentPlayer
        end

        it "should not force the current player to discard down to hand limit until their first turn is over" do
            pending("This has been thuroughly broken and needs to be fixed")
            # setup
            input_stream = StringIO.new("0\n0\n0\n0\n0\n0\n0\n")
            testLogger = Logger.new(test_outfile)
            theGame = Game.new(testLogger)
            theGame.ruleBase.addRule(Limit.new("low hand limit", 3, "no cards", 0))
            theFirstPlayer = theGame.players[0]
            theFirstPlayer.hand.unshift(Action.new(15, "another turn", "some rules text"))

            # execute
            theGame.playCards(theFirstPlayer)

            # test
            startingHandSize = 3 + 1 # since we now draw cards in the playCards method
            expect(theFirstPlayer.hand.size).to eq startingHandSize
        end
    end

    describe "exchange_keepers" do
        it "should not do anything if you have no keepers" do
            # setup
            input_stream = StringIO.new("")
            testLogger = Logger.new(test_outfile)
            testInterface = TestInterface.new(input_stream, test_outfile)
            numberOfPlayers = 3
            players = Player.generate_players(numberOfPlayers)
            theGame = Game.new(testLogger, testInterface, players)
            theFirstPlayer = theGame.players[0]

            # execute
            theGame.exchange_keepers(theFirstPlayer)

            # test
            # a hacky way to check that there was no prompt
            expect(testInterface.prompted).to be nil
        end

        it "should prompt the player if the player and at least one opponent has a keeper" do
            # setup
            input_stream = StringIO.new("1\n")
            testLogger = Logger.new(test_outfile)
            testInterface = TestInterface.new(input_stream, test_outfile, Constants::PROMPT_STRINGS)
            numberOfPlayers = 3
            players = Player.generate_players(numberOfPlayers)
            theGame = Game.new(testLogger, testInterface, players)
            theFirstPlayer = theGame.players[0]
            theFirstPlayer.keepers << Keeper.new(0, "thing1")
            theGame.players[1].keepers << Keeper.new(0, "thing2")

            # execute
            theGame.exchange_keepers(theFirstPlayer)

            # test
            expect(testInterface.prompted).to_not be nil
        end

        it "should not change the number of keepers either player has" do
            # setup
            input_stream = StringIO.new("1\n0\n0\n")
            testLogger = Logger.new(test_outfile)
            testInterface = TestInterface.new(input_stream, test_outfile, Constants::PROMPT_STRINGS)
            numberOfPlayers = 3
            players = Player.generate_players(numberOfPlayers)
            theGame = Game.new(testLogger, testInterface, players)
            theFirstPlayer = theGame.players[0]
            theFirstPlayer.keepers << Keeper.new(0, "thing1")
            firstPlayersOriginalKeeperCount = theFirstPlayer.keepers.size
            theSecondPlayer = theGame.players[1]
            theSecondPlayer.keepers << Keeper.new(0, "thing2")
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
            testLogger = Logger.new(test_outfile)
            testInterface = TestInterface.new(input_stream, test_outfile, Constants::PROMPT_STRINGS)
            numberOfPlayers = 3
            players = Player.generate_players(numberOfPlayers)
            theGame = Game.new(testLogger, testInterface, players)
            theFirstPlayer = theGame.players[0]
            firstPlayersOriginalKeeper = Keeper.new(0, "thing1")
            theFirstPlayer.keepers << firstPlayersOriginalKeeper
            theSecondPlayer = theGame.players[1]
            secondPLayersOriginalKeeper = Keeper.new(0, "thing2")
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
            testLogger = Logger.new(test_outfile)
            testInterface = TestInterface.new(input_stream, test_outfile, Constants::PROMPT_STRINGS)
            numberOfPlayers = 3
            players = Player.generate_players(numberOfPlayers)
            theGame = Game.new(testLogger, testInterface, players)
            theFirstPlayer = theGame.players[0]
            firstPlayersOriginalKeeper = Keeper.new(0, "thing1")
            theFirstPlayer.keepers << firstPlayersOriginalKeeper
            theSecondPlayer = theGame.players[1]
            secondPLayersOriginalKeeper = Keeper.new(0, "thing2")
            theSecondPlayer.keepers << secondPLayersOriginalKeeper

            # execute
            theGame.exchange_keepers(theFirstPlayer)

            # test
            expect(testInterface.card_list).to_not include theGame.players[2].to_s
        end

        it "should not prompt to check if you are sure of your decision" do
            # setup
            input_stream = StringIO.new("0\ny\n")
            testLogger = Logger.new(test_outfile)
            testInterface = TestInterface.new(input_stream, test_outfile, Constants::PROMPT_STRINGS)
            numberOfPlayers = 3
            players = Player.generate_players(numberOfPlayers)
            theGame = Game.new(testLogger, testInterface, players)
            theFirstPlayer = theGame.players[0]
            firstPlayersOriginalKeeper = Keeper.new(0, "thing1")
            theFirstPlayer.keepers << firstPlayersOriginalKeeper
            theSecondPlayer = theGame.players[1]
            secondPLayersOriginalKeeper = Keeper.new(0, "thing2")
            theSecondPlayer.keepers << secondPLayersOriginalKeeper

            # execute
            theGame.exchange_keepers(theFirstPlayer)

            # test
            #  This is stand in. if everyone keeps theier starting keepers
            #  then an exchange did not happen
            expect(theFirstPlayer.keepers[0]).to eq firstPlayersOriginalKeeper
            expect(theSecondPlayer.keepers[0]).to eq secondPLayersOriginalKeeper
        end

        it "should make sure that the originating player does not end up with war and peace" do
            # setup
            input_stream = StringIO.new("1\n0\n")
            testLogger = Logger.new(test_outfile)
            numberOfPlayers = 3
            players = Player.generate_players(numberOfPlayers)
            player_prompts = PlayerPromptGenerator.generate_prompts(players, Constants::USER_SPECIFIC_PROMPTS)
            testInterface = TestInterface.new(input_stream, test_outfile, Constants::PROMPT_STRINGS.merge(player_prompts))
            theGame = Game.new(testLogger, testInterface, players)
            theFirstPlayer = theGame.players[0]
            catKeeper = Keeper.new(1000, "Cat")
            peaceKeeper = Keeper.new(16, "a peace thing")
            warCreeper = Creeper.new(1, "a war kind of thing", "War is a scary place")
            theFirstPlayer.keepers << catKeeper
            theFirstPlayer.add_creeper(warCreeper)
            theSecondPlayer = theGame.players[1]
            theSecondPlayer.keepers << peaceKeeper

            # execute
            theGame.exchange_keepers(theFirstPlayer)

            # test
            expect(theFirstPlayer.creepers).to_not include warCreeper
        end

        it "should make sure that the other player does not end up with war and peace" do
            # setup
            input_stream = StringIO.new("1\n0\n")
            testLogger = Logger.new(test_outfile)
            numberOfPlayers = 3
            players = Player.generate_players(numberOfPlayers)
            player_prompts = PlayerPromptGenerator.generate_prompts(players, Constants::USER_SPECIFIC_PROMPTS)
            testInterface = TestInterface.new(input_stream, test_outfile, Constants::PROMPT_STRINGS.merge(player_prompts))
            theGame = Game.new(testLogger, testInterface, players)
            theFirstPlayer = theGame.players[0]
            catKeeper = Keeper.new(1000, "Cat")
            peaceKeeper = Keeper.new(16, "a peace thing")
            warCreeper = Creeper.new(1, "a war kind of thing", "War is a scary place")
            theFirstPlayer.keepers << peaceKeeper
            theSecondPlayer = theGame.players[1]
            theSecondPlayer.add_creeper(warCreeper)
            theSecondPlayer.keepers << catKeeper

            # execute
            theGame.exchange_keepers(theFirstPlayer)

            # test
            expect(theSecondPlayer.creepers).to_not include warCreeper
        end
    end

    describe "resolve_war_rule" do
        it "should ensure that if the player to play it has peace they don't end with it" do
            # setup
            input_stream = StringIO.new("0\n")
            testLogger = Logger.new(test_outfile)
            numberOfPlayers = 3
            players = Player.generate_players(numberOfPlayers)
            player_prompts = PlayerPromptGenerator.generate_prompts(players, Constants::USER_SPECIFIC_PROMPTS)
            testInterface = TestInterface.new(input_stream, test_outfile, player_prompts)
            theGame = Game.new(testLogger, testInterface, players)
            theFirstPlayer = theGame.players[0]
            theFirstPlayer.keepers << Keeper.new(16, "wanna be peace")
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
            testLogger = Logger.new(test_outfile)
            numberOfPlayers = 3
            players = Player.generate_players(numberOfPlayers)
            player_prompts = PlayerPromptGenerator.generate_prompts(players, Constants::USER_SPECIFIC_PROMPTS)
            testInterface = TestInterface.new(input_stream, test_outfile, player_prompts)
            theGame = Game.new(testLogger, testInterface, players)
            theFirstPlayer = theGame.players[0]
            theFirstPlayer.keepers << Keeper.new(16, "wanna be peace")
            warCreeper = Creeper.new(1, "War", "Some rules text")
            theFirstPlayer.creepers << warCreeper

            # execute
            theGame.resolve_war_rule(theFirstPlayer)

            # test
            expect(theGame.players[1].creepers).to include warCreeper
        end
    end

    describe "resolve_taxes_rule" do
        it "should make sure that if the player has taxes but not money they end up with taxes" do
            # setup
            input_stream = StringIO.new("")
            testLogger = Logger.new(test_outfile)
            testInterface = TestInterface.new(input_stream, test_outfile)
            numberOfPlayers = 3
            players = Player.generate_players(numberOfPlayers)
            theGame = Game.new(testLogger, testInterface, players)
            theFirstPlayer = theGame.players[0]
            taxesCreeper = Creeper.new(2, "Taxes", "Some rules text")
            theFirstPlayer.add_creeper(taxesCreeper)

            # execute
            theGame.resolve_taxes_rule(theFirstPlayer)

            # test
            expect(theFirstPlayer.creepers).to include taxesCreeper
        end

        it "should make sure that if the player has money but not taxes they end up with money" do
            # setup
            input_stream = StringIO.new("")
            testLogger = Logger.new(test_outfile)
            testInterface = TestInterface.new(input_stream, test_outfile)
            stacked_deck = StackedDeck.new(testLogger, cardsToPutOnTop=[], startEmpty=false, withCreepers=false)
            numberOfPlayers = 3
            players = Player.generate_players(numberOfPlayers)
            theGame = Game.new(testLogger, testInterface, players, stacked_deck)
            theFirstPlayer = theGame.players[0]
            moenyKeeper = Keeper.new(19, "Pennies")
            theFirstPlayer.keepers << moenyKeeper

            # execute
            theGame.resolve_taxes_rule(theFirstPlayer)

            # test
            expect(theFirstPlayer.keepers).to include moenyKeeper
        end

        it "should make sure that if the player has taxes and money they end up with neither" do
            # setup
            input_stream = StringIO.new("")
            testLogger = Logger.new(test_outfile)
            testInterface = TestInterface.new(input_stream, test_outfile)
            numberOfPlayers = 3
            players = Player.generate_players(numberOfPlayers)
            theGame = Game.new(testLogger, testInterface, players)
            theFirstPlayer = theGame.players[0]
            moenyKeeper = Keeper.new(19, "Pennies")
            theFirstPlayer.keepers << moenyKeeper
            taxesCreeper = Creeper.new(2, "Taxes", "Some rules text")
            theFirstPlayer.add_creeper(taxesCreeper)

            # execute
            theGame.resolve_taxes_rule(theFirstPlayer)

            # test
            expect(theFirstPlayer.creepers).to_not include taxesCreeper
            expect(theFirstPlayer.keepers).to_not include moenyKeeper
        end

        it "should result in both being discarded" do
            # setup
            input_stream = StringIO.new("")
            testLogger = Logger.new(test_outfile)
            testInterface = TestInterface.new(input_stream, test_outfile)
            numberOfPlayers = 3
            players = Player.generate_players(numberOfPlayers)
            theGame = Game.new(testLogger, testInterface, players)
            theFirstPlayer = theGame.players[0]
            moenyKeeper = Keeper.new(19, "Pennies")
            theFirstPlayer.keepers << moenyKeeper
            taxesCreeper = Creeper.new(2, "Taxes", "Some rules text")
            theFirstPlayer.add_creeper(taxesCreeper)

            # execute
            theGame.resolve_taxes_rule(theFirstPlayer)

            # test
            expect(theGame.discardPile).to include taxesCreeper
            expect(theGame.discardPile).to include moenyKeeper
        end
    end

    describe "resolve_death_rule" do
        it "should result in one less permanent" do
            # setup
            input_stream = StringIO.new("0\n")
            testLogger = Logger.new(test_outfile)
            testInterface = TestInterface.new(input_stream, test_outfile, Constants::PROMPT_STRINGS)
            numberOfPlayers = 3
            players = Player.generate_players(numberOfPlayers)
            theGame = Game.new(testLogger, testInterface, players)
            theFirstPlayer = theGame.players[0]
            moenyKeeper = Keeper.new(19, "Pennies")
            theFirstPlayer.keepers << moenyKeeper
            deathCreeper = Creeper.new(3, "dead", "Some rules text")
            theFirstPlayer.add_creeper(deathCreeper)
            numberOfStartingPermanents = theFirstPlayer.permanents.size

            # execute
            theGame.resolve_death_rule(theFirstPlayer)

            # test
            expect(theFirstPlayer.permanents.size).to eq numberOfStartingPermanents - 1
        end

        it "if death stand alone it should consume itself" do
            # setup
            input_stream = StringIO.new("")
            testLogger = Logger.new(test_outfile)
            testInterface = TestInterface.new(input_stream, test_outfile)
            stacked_deck = StackedDeck.new(testLogger, cardsToPutOnTop=[], startEmpty=false, withCreepers=false)
            numberOfPlayers = 3
            players = Player.generate_players(numberOfPlayers)
            theGame = Game.new(testLogger, testInterface, players, stacked_deck)
            theFirstPlayer = theGame.players[0]
            deathCreeper = Creeper.new(3, "dead", "Some rules text")
            theFirstPlayer.add_creeper(deathCreeper)
            numberOfStartingPermanents = theFirstPlayer.permanents.size

            # execute
            theGame.resolve_death_rule(theFirstPlayer)

            # test
            expect(theFirstPlayer.permanents.size).to eq numberOfStartingPermanents - 1
            expect(theFirstPlayer.permanents.size).to eq 0 # should be no remaining cards
        end
    end

    test_outfile.unlink
end
