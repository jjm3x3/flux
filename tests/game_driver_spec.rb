require "Tempfile"
require "./game.rb"
require "./game_driver.rb"

describe "GameDriver" do

    test_outfile = Tempfile.new 'test_output'

    describe "takeTurn" do
        it "should not call resolve_death_rule if they do not has_death?" do
            input_stream = StringIO.new("")
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            gameDouble = double("game", :drawCards => ["a card"])
            allow(gameDouble).to receive(:playCards)
            allow(gameDouble).to receive(:discardDownToLimit)
            allow(gameDouble).to receive(:removeDownToKeeperLimit)
            allow(gameDouble).to receive(:resolve_death_rule)
            gameDriver = GameDriver.new(gameDouble, theTestInterface)

            userDouble = double("user", :has_death? => false)
            allow(userDouble).to receive(:permanents).and_return([])
            allow(userDouble).to receive(:take_death)
            allow(userDouble).to receive(:drawCards)
            allow(userDouble).to receive(:hand).and_return([])
            allow(userDouble).to receive(:keepers).and_return([])

            # execute
            gameDriver.takeTurn(userDouble)

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
            gameDriver = GameDriver.new(gameDouble, theTestInterface)

            userDouble = double("user", :has_death? => true)
            allow(userDouble).to receive(:permanents).and_return([])
            allow(userDouble).to receive(:take_death)
            allow(userDouble).to receive(:drawCards)
            allow(userDouble).to receive(:hand).and_return([])
            allow(userDouble).to receive(:keepers).and_return([])

            # execute
            gameDriver.takeTurn(userDouble)

            # test
            expect(gameDouble).to have_received(:resolve_death_rule)
        end
    end

    test_outfile.unlink
end