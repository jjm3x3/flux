require "Tempfile"
require "./game.rb"
require "./game_driver.rb"

describe "GameDriver" do

    test_outfile = Tempfile.new 'test_output'

    describe "setup_new_turn" do
        it "should not call resolve_death_rule if they do not has_death?" do
            input_stream = StringIO.new("")
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            gameDouble = double("game", :drawCards => ["a card"])
            allow(gameDouble).to receive(:playCards)
            allow(gameDouble).to receive(:discardDownToLimit)
            allow(gameDouble).to receive(:removeDownToKeeperLimit)
            allow(gameDouble).to receive(:resolve_death_rule)

            playerDouble = double("player", :has_death? => false)
            allow(playerDouble).to receive(:add_cards_to_hand)

            allow(gameDouble).to receive(:active_player).and_return(playerDouble)
            gameDriver = GameDriver.new(gameDouble, theTestInterface)

            # execute
            gameDriver.setup_new_turn

            # test
            expect(gameDouble).to_not have_received(:resolve_death_rule)
        end

        it "should call resolve_death_rule if they has_death?" do
            input_stream = StringIO.new("")
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            gameDouble = double("game", :drawCards => ["a card"])
            allow(gameDouble).to receive(:playCards)
            allow(gameDouble).to receive(:discardDownToLimit)
            allow(gameDouble).to receive(:removeDownToKeeperLimit)
            allow(gameDouble).to receive(:resolve_death_rule)

            playerDouble = double("player", :has_death? => true)
            allow(playerDouble).to receive(:add_cards_to_hand)

            allow(gameDouble).to receive(:active_player).and_return(playerDouble)
            gameDriver = GameDriver.new(gameDouble, theTestInterface)

            # execute
            gameDriver.setup_new_turn

            # test
            expect(gameDouble).to have_received(:resolve_death_rule)
        end
    end

    describe "post_card_play_clean_up" do
        it "should play cards..... :?" do
            # setup
            input_stream = StringIO.new("0\n")
            theTestInterface = TestInterface.new(input_stream,test_outfile)

            cardDouble = double("card", :play => nil)
            gameDouble = double("game")
            allow(gameDouble).to receive(:winner).and_return(false)
            allow(gameDouble).to receive(:enforceNonActivePlayerLimits)
            allow(gameDouble).to receive(:discardPile).and_return([])
            allow(gameDouble).to receive(:replenishHand)
            gameDriver = GameDriver.new(gameDouble, theTestInterface)
            playerDouble = double("player")

            # execute
            gameDriver.post_card_play_clean_up(playerDouble, cardDouble)

            # test
            expect(cardDouble).to have_received(:play)
        end
    end

    test_outfile.unlink
end