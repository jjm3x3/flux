require "./game.rb"
require "io/console"

game = Game.new($stdin, 3, CliInterface.new)
game.run




