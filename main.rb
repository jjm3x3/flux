require "./game.rb"
require "./game_interface.rb"

game = Game.new(3, CliInterface.new)
game.run




