require "./game.rb"
require "io/console"

game = Game.new($stdin, $stdout, 3, CliInterface.new)
game.run




