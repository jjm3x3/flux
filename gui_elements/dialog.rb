require "./gui_elements/zorder.rb"

class Dialog
    def initialize(window)
        @visible = false
        @baground_image = Gosu::Image.new("assets/onlineGreenSquare2.png", tileable: true)
        @font = Gosu::Font.new(20)
        @yes_button = Button.new(window, "Yes", 120, 120, ZOrder::DIALOG_ITEMS)
        widthOfYesButtonGuess = 30
        spaceBetweenButtonts = 40
        @no_button = Button.new(window, "No", 120 + widthOfYesButtonGuess + spaceBetweenButtonts, 120, ZOrder::DIALOG_ITEMS  )
    end

    def draw
        if @visible
            @baground_image.draw(100, 100, ZOrder::DIALOG, 0.25, 0.25)
            @yes_button.set_visibility true
            @no_button.set_visibility true
            @yes_button.draw
            @no_button.draw
        end
    end

    def show
        @visible = true
        @yes_button.set_visibility true
        @no_button.set_visibility true
    end

    def hide
        @visible = false
        @yes_button.set_visibility false
        @no_button.set_visibility false
    end

    def is_visible?
        @visible
    end

    def handle_result
        if @yes_button.is_clicked?
            yield(:yes_clicked)
        elsif @no_button.is_clicked?
            yield(:no_clicked)
        else
            yield(:nothing_clicked)
        end
    end

end

class CardDialog
    def initialize(window)
        @window = window
        @visible = false
        @baground_image = Gosu::Image.new("assets/onlineGreenSquare2.png", tileable: true)
        @font = Gosu::Font.new(20)
        @card_buttons = []
        @result = Concurrent::AtomicReference.new
        @current_result = nil
    end

    def set_cards(card_list)
        @card_list = card_list
        cardsDisplayed = 0
        card_list.each do |card|
            @card_buttons << Button.new(@window, "#{card}", 120, 120 + 10 * cardsDisplayed + @font.height * cardsDisplayed, ZOrder::DIALOG_ITEMS)
            cardsDisplayed += 1
        end

    end

    def set_selection_callback(&block)
        @handle_result_block = block
    end

    def draw
        if @visible
            @baground_image.draw(100, 100, ZOrder::DIALOG, 0.25, 0.25)
            @card_buttons.each do |card_button|
                card_button.draw
            end
        end
    end

    def show
        @visible = true
        @card_buttons.each do |card_button|
            card_button.set_visibility true
        end
    end

    def hide
        @visible = false
        @card_buttons.each do |card_button|
            card_button.set_visibility false
        end
    end

    def is_visible?
        @visible
    end

    def set_response(new_i_var)
        @current_result = new_i_var
    end

    def get_result
        @result.get
    end

    def reset_result
        @result.set(nil)
    end

    def handle_result
        cardIndex = 0
        @card_buttons.each do |card_button|
            if card_button.is_clicked?
                selectedCard = @card_list[cardIndex]
                puts "#{selectedCard} was selected"
                # if @handle_result_block
                #     @handle_result_block.call(selectedCard)
                # end
                @result.set(selectedCard)
                @current_result.set selectedCard
                return true
            end
            cardIndex += 1
        end
        return false
    end
end