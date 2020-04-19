class GameStats
    def initialize(x, y)
        @x = x
        @y = y

        @font = Gosu::Font.new(20)
    end

    def draw(game)
        margin = 10
        previous_lines = 0
        next_text_y = @y + margin * previous_lines + @font.height * previous_lines
        @font.draw_text("The deck has #{game.deck.count} cards in it", @x, next_text_y, 1, 1.0, 1.0, Gosu::Color::WHITE)
        previous_lines += 1
        next_text_y = @y + margin * previous_lines + @font.height * previous_lines
        @font.draw_text("The discard pile has #{game.discardPile.size} cards in it", @x, next_text_y, 1, 1.0, 1.0, Gosu::Color::WHITE)
        previous_lines += 1
        next_text_y = @y + margin * previous_lines + @font.height * previous_lines
        @font.draw_text("The Current rules are: #{game.ruleBase}", @x, next_text_y, 1, 1.0, 1.0, Gosu::Color::WHITE)
    end
end