class GameStats
    def initialize(x, y)
        @x = x
        @y = y

        @font = Gosu::Font.new(20)

        @margin = 10
    end

    def draw(game)
        previous_lines = 0
        next_text_y = @y + @margin * previous_lines + @font.height * previous_lines
        @font.draw_text("The deck has #{game.deck.count} cards in it", @x, next_text_y, 1, 1.0, 1.0, Gosu::Color::WHITE)
        previous_lines += 1
        next_text_y = @y + @margin * previous_lines + @font.height * previous_lines
        @font.draw_text("The discard pile has #{game.discardPile.size} cards in it", @x, next_text_y, 1, 1.0, 1.0, Gosu::Color::WHITE)
        previous_lines += 1
        next_text_y = @y + @margin * previous_lines + @font.height * previous_lines
        @font.draw_text("The Current rules are: #{game.ruleBase}", @x, next_text_y, 1, 1.0, 1.0, Gosu::Color::WHITE)
    end

    def height
        height_up_to_rules = @margin * 2 + @font.height * 2

        number_of_rules = 4
        rule_spacer = 0
        rules_text_title = @font.height
        height_of_rules = rules_text_title + rule_spacer * number_of_rules + @font.height * number_of_rules

        height_up_to_rules + height_of_rules
    end
end