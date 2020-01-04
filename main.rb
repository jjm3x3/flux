require "./game.rb"
require "./game_interface.rb"

debug=false

ARGV.each do |arg|
  if arg[0] == '-' && arg[1] == '-'
    if arg[2..-1] == "debug"
      debug=true
    end
  end
end

game = Game.new(3, CliInterface.new(debug))
game.run




