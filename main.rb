require "./game.rb"
require "gosu"

class GameWindow < Gosu::Window
  def initialize(width=320, height=240, fullscreen=false)
    super
    self.caption = 'Fluxx'
    @message = Gosu::Image.from_text(
      self, 'something', Gosu.default_font_name, 30)
  end

  def draw
    @message.draw(10,10,0)
  end

end

HEADLESS=false

ARGV.each do |arg|
  if arg[0] == '-' && arg[1] == '-'
    if arg[2..-1] == "headless"
      HEADLESS=true
    end
  end
end

if HEADLESS
  game = Game.new
  game.run
else
  puts "huh?!"
  window = GameWindow.new
  window.show
end




