require "tempfile"
require "./game.rb"
require "./game_driver.rb"

describe "GameDriver" do

    test_outfile = Tempfile.new 'test_output'

    describe "setup_new_turn" do
        it "should not call resolve_death_rule if they do not has_death?" do
            test_logger = Logger.new(test_outfile)
            theDeck = Deck.new(test_logger)
            gameDouble = double("game", :drawCards => ["a card"])
            allow(gameDouble).to receive(:playCards)
            allow(gameDouble).to receive(:discardDownToLimit)
            allow(gameDouble).to receive(:removeDownToKeeperLimit)
            allow(gameDouble).to receive(:resolve_death_rule)

            playerDouble = double("player", :has_death? => false)
            allow(playerDouble).to receive(:add_cards_to_hand)

            allow(gameDouble).to receive(:active_player).and_return(playerDouble)
            gameDriver = GameDriver.new(gameDouble, test_logger)

            # execute
            gameDriver.setup_new_turn

            # test
            expect(gameDouble).to_not have_received(:resolve_death_rule)
        end

        it "should call resolve_death_rule if they has_death?" do
            test_logger = Logger.new(test_outfile)
            gameDouble = double("game", :drawCards => ["a card"])
            allow(gameDouble).to receive(:playCards)
            allow(gameDouble).to receive(:discardDownToLimit)
            allow(gameDouble).to receive(:removeDownToKeeperLimit)
            allow(gameDouble).to receive(:resolve_death_rule)

            playerDouble = double("player", :has_death? => true)
            allow(playerDouble).to receive(:add_cards_to_hand)

            allow(gameDouble).to receive(:active_player).and_return(playerDouble)
            gameDriver = GameDriver.new(gameDouble, test_logger)

            # execute
            gameDriver.setup_new_turn

            # test
            expect(gameDouble).to have_received(:resolve_death_rule)
        end
    end

    describe "play_card" do
        it "should play a card" do
            # setup
            test_logger = Logger.new(test_outfile)

            cardDouble = double("card", :play => nil)
            gameDouble = double("game")
            allow(gameDouble).to receive(:winner).and_return(false)
            allow(gameDouble).to receive(:enforceNonActivePlayerLimits)
            allow(gameDouble).to receive(:discardPile).and_return([])
            allow(gameDouble).to receive(:replenishHand)
            allow(gameDouble).to receive(:play_card)
            allow(gameDouble).to receive(:active_player).and_return(Player.new("Goeff"))
            allow(gameDouble).to receive(:play_limit).and_return(1)
            allow(gameDouble).to receive(:discardDownToLimit)
            allow(gameDouble).to receive(:removeDownToKeeperLimit)
            allow(gameDouble).to receive(:progress_turn)
            gameDriver = GameDriver.new(gameDouble, test_logger)
            playerDouble = double("player")

            # execute
            gameDriver.play_card(cardDouble)

            # test
            expect(gameDouble).to have_received(:play_card)

        end
    end

    describe "post_card_play_clean_up" do
        it "should not play cards" do
            # setup
            test_logger = Logger.new(test_outfile)

            cardDouble = double("card", :play => nil)
            gameDouble = double("game")
            allow(gameDouble).to receive(:winner).and_return(false)
            allow(gameDouble).to receive(:enforceNonActivePlayerLimits)
            allow(gameDouble).to receive(:discardPile).and_return([])
            allow(gameDouble).to receive(:replenishHand)
            allow(gameDouble).to receive(:play_card)
            allow(gameDouble).to receive(:active_player).and_return(Player.new("Goeff"))
            allow(gameDouble).to receive(:play_limit).and_return(1)
            allow(gameDouble).to receive(:discardDownToLimit)
            allow(gameDouble).to receive(:removeDownToKeeperLimit)
            allow(gameDouble).to receive(:progress_turn)
            gameDriver = GameDriver.new(gameDouble, test_logger)
            playerDouble = double("player")

            # execute
            gameDriver.post_card_play_clean_up

            # test
            expect(gameDouble).to_not have_received(:play_card)
        end
    end

    describe "end_turn_cleanup" do
        it "should not progress the turn if the current player is set to take another turn" do
            # setup
            test_logger = Logger.new(test_outfile)

            player_double = double(
                "player_double",
                take_another_turn: true,
                set_take_another_turn: nil)
            gameDouble = double(
                "game",
                active_player: player_double,
                discardDownToLimit: nil,
                removeDownToKeeperLimit: nil,
                progress_turn: nil)
            gameDriver = GameDriver.new(gameDouble, test_logger)

            # execute
            gameDriver.end_turn_cleanup

            # test
            expect(gameDouble).to_not have_received(:progress_turn)
        end

    end

    test_outfile.unlink
end
