require "Tempfile"
require "./game.rb"

describe "player" do

    test_outfile = Tempfile.new 'test_output'

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

    test_outfile.unlink
end