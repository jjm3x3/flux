require "Tempfile"
require "io/console"
require "./deck.rb"
require "./game_interface.rb"

describe "deck" do
    test_outfile = Tempfile.new 'test_output'

    describe "drawACard" do
        it "should not break if there are no more cards to draw" do
            # setup
            input_stream = StringIO.new("0")
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            theDeck = Deck.new(theTestInterface)

            # execute, test
            # this should not break!
            (1..100).each do |itteration|
                theDeck.send(:drawACard)
            end
        end
    end

    describe "drawCards" do
        it "should attempt to draw as many cards as it can" do
            # setup
            input_stream = StringIO.new("0")
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            theDeck = Deck.new(theTestInterface)
            # setup the deck so there is only one card left to draw
            (1..(theDeck.count-1)).each do |itteration|
                theDeck.send(:drawACard)
            end

            drawnCards = theDeck.drawCards

            expect(drawnCards.size).to eq 1
        end

        it "Should return an empty list if it can not draw 1 card" do
            # setup
            input_stream = StringIO.new("0")
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            theDeck = Deck.new(theTestInterface)
            # setup the deck so there is only one card left to draw
            (1..100).each do |itteration|
                theDeck.send(:drawACard)
            end

            drawnCards = theDeck.drawCards

            expect(drawnCards.size).to eq 0
        end

        it "Should return an empty list if it can not draw any cards" do
            # setup
            input_stream = StringIO.new("0")
            theTestInterface = TestInterface.new(input_stream, test_outfile)
            theDeck = Deck.new(theTestInterface)
            # setup the deck so there is only one card left to draw
            (1..100).each do |itteration|
                theDeck.send(:drawACard)
            end

            drawnCards = theDeck.drawCards(3)

            expect(drawnCards.size).to eq 0
        end
    end

    test_outfile.unlink
end