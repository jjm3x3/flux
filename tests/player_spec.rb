require "Tempfile"
require "./game.rb"

describe "player" do

    test_outfile = Tempfile.new 'test_output'

    describe "takeTurn" do
        it "should not call resolve_death_rule if they do not has_death?" do
            fakeGame = Object.new
            gameDouble = double("game", :drawCards => ["a card"])
            allow(gameDouble).to receive(:playCards)
            allow(gameDouble).to receive(:discardDownToLimit)
            allow(gameDouble).to receive(:removeDownToKeeperLimit)
            allow(gameDouble).to receive(:resolve_death_rule)
            fakePlayer = Player.new("fake boi", gameDouble)

            # execute
            fakePlayer.takeTurn

            # test
            expect(gameDouble).to_not have_received(:resolve_death_rule)
        end

        it "should call resolve_death_rule if they has_death?" do
            fakeGame = Object.new
            gameDouble = double("game", :drawCards => ["a card"])
            allow(gameDouble).to receive(:playCards)
            allow(gameDouble).to receive(:discardDownToLimit)
            allow(gameDouble).to receive(:removeDownToKeeperLimit)
            allow(gameDouble).to receive(:resolve_death_rule)
            fakePlayer = Player.new("fake boi", gameDouble)
            deathCreepepr1 = Creeper.new(3, "wanna be death", "you cannot win heh heh")
            fakePlayer.add_permanent(deathCreepepr1)

            # execute
            fakePlayer.takeTurn

            # test
            expect(gameDouble).to have_received(:resolve_death_rule)
        end
    end

    describe "won?" do
        it "should return false if the game has no goal" do
            # setup
            input_stream = StringIO.new("")
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            theGame = Game.new(numberOfPlayers=3, theTestInterface)
            theFirstPlayer = theGame.players[0]
            # asume that a new game has no goal

            # execute, test
            expect(theFirstPlayer.won?).to be false
        end

        it "should return true if the goal has been met" do
            # setup
            input_stream = StringIO.new("")
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            theGame = Game.new(numberOfPlayers=3, theTestInterface)
            keeper1 = Keeper.new(1, "thing1")
            keeper2 = Keeper.new(2, "thing2")
            theGame.setGoal(Goal.new("do a thing", [keeper1, keeper2], "some rule text"))
            theFirstPlayer = theGame.players[0]
            theFirstPlayer.keepers << keeper1
            theFirstPlayer.keepers << keeper2

            # execute, test
            expect(theFirstPlayer.won?).to be true
        end

        it "should return false if the goal has been met but the player has any creepers" do
            # setup
            input_stream = StringIO.new("")
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            theGame = Game.new(numberOfPlayers=3, theTestInterface)
            keeper1 = Keeper.new(1, "thing1")
            keeper2 = Keeper.new(2, "thing2")
            theGame.setGoal(Goal.new("do a thing", [keeper1, keeper2], "some rule text"))
            theFirstPlayer = theGame.players[0]
            theFirstPlayer.keepers << keeper1
            theFirstPlayer.keepers << keeper2
            theFirstPlayer.add_creeper(Creeper.new(1, "pure evil", "some evil rule thing"))

            # execute, test
            expect(theFirstPlayer.won?).to be false
        end
    end

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