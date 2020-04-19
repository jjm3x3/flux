require "Tempfile"
require "./game.rb"

describe "player" do

    test_outfile = Tempfile.new 'test_output'

    describe "add_permanenet" do
        it "should add a keeper to the players keeper collection if the card is a keeper" do
            # setup
            input_stream = StringIO.new("")
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            theGame = Game.new(numberOfPlayers=3, theTestInterface)
            keeper1 = Keeper.new(1, "thing1")
            theFirstPlayer = theGame.players[0]

            # execute
            theFirstPlayer.add_permanent(keeper1)
        end

        it "should add a keeper to the players keeper collection if the card is a keeper extra lite version" do
            # setup
            thePlayer = Player.new("JOE", nil)
            keeper1 = Keeper.new(1, "thing1")

            # execute
            thePlayer.add_permanent(keeper1)
        end
    end

    describe "has_death?" do
        it "should return false if the player does not have the death creeper in front of them" do
            # setup
            thePlayer = Player.new("JOE", nil)
            deathCreepepr1 = Creeper.new(3, "wanna be death", "you cannot win heh heh")

            # execute, test
            expect(thePlayer.has_death?).to be false
        end

        it "should return true if the player has death creeper in front of them" do
            # setup
            thePlayer = Player.new("JOE", nil)
            deathCreepepr1 = Creeper.new(3, "wanna be death", "you cannot win heh heh")
            thePlayer.add_permanent(deathCreepepr1)

            # execute, test
            expect(thePlayer.has_death?).to be true
        end
    end

    test_outfile.unlink
end