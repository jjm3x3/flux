require "tempfile"
require "./game_interface.rb"
require "./player.rb"
require "./deck.rb"
require "./logger.rb"

describe "BaseLogger" do

    test_outfile = Tempfile.new 'test_output'


    test_outfile.unlink
end