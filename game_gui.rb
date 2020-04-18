require 'gosu'

class GameGui < Gosu::Window
    def initialize
        super 640, 480
        self.caption = "Fluxx"
    end

    def update

    end

    def draw
    end
end

GameGui.new.show