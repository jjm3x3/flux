class PlayerPermanents
    def initialize(font, color)
        @font = font
        @color = color
    end

    def draw(active_player, x, y)
        @font.draw_text("Here are the permanents they have:", x, y, 1, 1.0, 1.0, @color)

        permanentsDisplayed = 0
        permananent_margin = 5
        permanents_start_y = y + 30
        perm_x = x + 20
        active_player.permanents.each do |card|
            if permanentsDisplayed >= 3
                permanentsDisplayed = 0
                perm_x += 100
            end
            next_y = permanents_start_y + @font.height * permanentsDisplayed + permananent_margin * permanentsDisplayed
            @font.draw_text("#{card}", perm_x, next_y, 1, 1.0, 1.0, @color)
            permanentsDisplayed += 1
        end
        # permanents_height = activePlayer.permanents.length * @font.height + activePlayer.permanents.length * permananent_margin
    end
end