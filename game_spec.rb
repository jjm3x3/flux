require "./game.rb"
require "Tempfile"

describe "game" do
    it "should construct" do
        test_oufile = Tempfile.new 'test_output'
        Game.new("input_stream", test_oufile)
        test_oufile.unlink
    end 

end
