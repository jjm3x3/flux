require "./game.rb"
require "gosu"

class Card
  def initializ()

  end

  def draw(x,y,z=0)
    Gosu.draw_rect(10,10,40,80,Gosu::Color.argb(0xff_ff0000))
  end
end

class GameWindow < Gosu::Window
  def initialize(width=320, height=240, fullscreen=true)
    super
    self.caption = 'Fluxx'
    @message = Gosu::Image.from_text(
      self, 'somethingAnd something else', Gosu.default_font_name, 8)
    @rect = Card.new
  end

  def draw
    # @rect.draw(10,10)
    @message.draw(10,10,0)
  end

  def button_down(id)
    if id == Gosu::MsLeft
      puts mouse_x
      puts mouse_y
    end
  end

  def find_card(x,y)

  end

  def needs_cursor?
    true
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
  window = GameWindow.new
  window.show
end




