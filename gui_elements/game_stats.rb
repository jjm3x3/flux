class GameStats
    def initialize(x, y)
        @x = x
        @y = y
        @rule_x = x + 10

        @font = Gosu::Font.new(20)

        @margin = 10
        @rule_margin = 0
    end

    def draw(game)
        previous_rules = 0
        previous_lines = 0
        next_text_y = @y + @margin * previous_lines + @font.height * previous_lines
        @font.draw_text("The deck has #{game.deck.count} cards in it", @x, next_text_y, 1, 1.0, 1.0, Gosu::Color::WHITE)
        previous_lines += 1
        next_text_y = @y + @margin * previous_lines + @font.height * previous_lines
        @font.draw_text("The discard pile has #{game.discardPile.size} cards in it", @x, next_text_y, 1, 1.0, 1.0, Gosu::Color::WHITE)
        previous_lines += 1
        next_text_y = @y + @margin * previous_lines + @font.height * previous_lines
        @font.draw_text("The Current Goal is: #{game.goal}", @x, next_text_y, 1, 1.0, 1.0, Gosu::Color::WHITE)
        previous_lines += 1
        next_text_y = @y + @margin * previous_lines + @font.height * previous_lines
        @font.draw_text("The Current rules are:", @x, next_text_y, 1, 1.0, 1.0, Gosu::Color::WHITE)
        previous_rules += 1
        next_text_y = @y + @margin * previous_lines  + @rule_margin * previous_rules + @font.height * (previous_lines + previous_rules)
        @font.draw_text("Draw: #{game.ruleBase.drawRule}", @rule_x, next_text_y, 1, 1.0, 1.0, Gosu::Color::WHITE)
        previous_rules += 1
        next_text_y = @y + @margin * previous_lines  + @rule_margin * previous_rules + @font.height * (previous_lines + previous_rules)
        @font.draw_text("Play: #{game.ruleBase.playRule}", @rule_x, next_text_y, 1, 1.0, 1.0, Gosu::Color::WHITE)
        previous_rules += 1
        next_text_y = @y + @margin * previous_lines  + @rule_margin * previous_rules + @font.height * (previous_lines + previous_rules)
        @font.draw_text("Hand Limit: #{game.ruleBase.handLimit}", @rule_x, next_text_y, 1, 1.0, 1.0, Gosu::Color::WHITE)
        previous_rules += 1
        next_text_y = @y + @margin * previous_lines  + @rule_margin * previous_rules + @font.height * (previous_lines + previous_rules)
        @font.draw_text("Keeper Limit: #{game.ruleBase.keeperLimit}", @rule_x, next_text_y, 1, 1.0, 1.0, Gosu::Color::WHITE)
    end

    def height
        height_up_to_rules = @margin * 3 + @font.height * 3

        number_of_rules = 4
        rule_spacer = 0
        rules_text_title = @font.height
        height_of_rules = rules_text_title + rule_spacer * number_of_rules + @font.height * number_of_rules

        height_up_to_rules + height_of_rules
    end
end