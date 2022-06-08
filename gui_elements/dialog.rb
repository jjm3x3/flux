require "./gui_elements/zorder.rb"

class Dialog
    def initialize(window, button_options)
        @visible = false
        @baground_image = Gosu::Image.new("assets/onlineGreenSquare2.png", tileable: true)
        @font = Gosu::Font.new(20)
        @yes_button = Button.new(window, @font, "Yes", 120, 120, ZOrder::DIALOG_ITEMS, button_options)
        widthOfYesButtonGuess = 30
        spaceBetweenButtonts = 40
        @no_button = Button.new(window, @font, "No", 120 + widthOfYesButtonGuess + spaceBetweenButtonts, 120, ZOrder::DIALOG_ITEMS, button_options)
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
    def initialize(window, background, font, logger, dialog_prompts, button_options)
        @window = window
        @logger = logger
        @visible = false
        @background = background
        @font = font
        @button_options = button_options
        @card_buttons = []
        @selected_card = nil
        @dialog_x_position = 100
        @dialog_y_position = 100
        @boarder_width = 20
        @dialog_content_x_position = @dialog_x_position + @boarder_width
        @dialog_content_y_position = @dialog_y_position + @boarder_width
        @item_spacing = 10
        @dialog_prompts = dialog_prompts
        @current_prompt_image = dialog_prompts[:default]
        @width = 300
    end

    def add_prompt(symbol, prompt_image)
        @dialog_prompts[symbol] = prompt_image
    end

    def set_cards(card_list)
        @card_list = card_list
        @card_buttons = []
        cardsDisplayed = 1 # accounts for prompt
        card_list.each do |card|
            #TODO:: need to generate these statically
            @card_buttons << Button.new(@window, @font, "#{card}",
                                @dialog_content_x_position,
                                @dialog_content_y_position + @item_spacing * cardsDisplayed + @font.height * cardsDisplayed,
                                ZOrder::DIALOG_ITEMS,
                                @button_options)
            cardsDisplayed += 1
        end

    end

    def draw
        if @visible
            x_scale = @width / @background.width
            @background.draw(@dialog_x_position, @dialog_y_position, ZOrder::DIALOG, x_scale, 30)

            @current_prompt_image.draw(@dialog_content_x_position, @dialog_content_y_position, ZOrder::DIALOG_ITEMS)
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

    def get_result
        @selected_card
    end

    def reset_result
        @selected_card = nil
    end

    def set_prompt(prompt_key)
        @logger.debug "set_prompt: got prompt_key: '#{prompt_key}'"
        if !prompt_key; raise "prompt_key is nil"; end
        if !@dialog_prompts.has_key? prompt_key; raise "prompt_key missing from prompts collection"; end
        @current_prompt_image = @dialog_prompts[prompt_key]
    end

    def handle_result
        cardIndex = 0
        @card_buttons.each do |card_button|
            if card_button.is_clicked?
                selectedCard = @card_list[cardIndex]
                puts "#{selectedCard} was selected"
                @selected_card = selectedCard
                return true
            end
            cardIndex += 1
        end
        return false
    end
end