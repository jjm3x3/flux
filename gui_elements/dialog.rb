require "./gui_elements/button.rb"
require "./gui_elements/zorder.rb"

class SimpleDialog
    def self.generate_dialog_options(list, images)
        list_options = []
        list.each do |item|
            list_option = {item: item}
            if !images.has_key? item.to_s; raise "No image found for item #{item.to_s} in image hash"; end
            list_option[:image] = images[item.to_s]
            list_options << list_option
        end
        return list_options
    end

    def initialize(window, background, font, logger, dialog_prompts, button_options)
        @window = window
        @background = background
        @font = font
        @logger = logger
        @dialog_prompts = dialog_prompts
        @current_prompt_image = dialog_prompts[:default]
        @button_options = button_options
        @visible = false

        @option_buttons = []
        @selected_option = nil
        @dialog_x_position = 100
        @dialog_y_position = 100
        @boarder_width = 20
        @item_spacing = 10

        # height is assigned fairly arbitrarily here (assumes 3 options and prompt = 4)
        @height = (@font.height + @item_spacing) * 4 + @boarder_width * 2
        @width = 300
    end

    def check_clicked
        @previous_x = @window.mouse_x
        @previous_y = @window.mouse_y
        return is_clicked?
    end

    def add_prompt(symbol, prompt_image)
        @dialog_prompts[symbol] = prompt_image
    end

    def set_options(list)
        @option_list = list
        @option_buttons = []
        items_displayed = 1 # accounts for prompt
        list.each do |card|
            #TODO:: need to generate these statically
            @option_buttons << Button.new(
                                @window,
                                @font,
                                "#{card}",
                                dialog_content_x_position,
                                dialog_content_y_position + @item_spacing * items_displayed + @font.height * items_displayed,
                                ZOrder::DIALOG_ITEMS,
                                @button_options)
            items_displayed += 1
        end
        # note cardsDisaplyed is really cardsDisplayed + 1 for the prompt
        @height = (@font.height + @item_spacing) * items_displayed + @boarder_width * 2
    end

    def draw
        if !@current_prompt_image; raise "Cannot draw a dialog without setting the prompt"; end
        if @visible
            x_scale = @width / @background.width
            y_scale = @height / @background.height
            @background.draw(@dialog_x_position, @dialog_y_position, ZOrder::DIALOG, x_scale, y_scale)

            @current_prompt_image.draw(dialog_content_x_position, dialog_content_y_position, ZOrder::DIALOG_ITEMS)
            @option_buttons.each do |option_button|
                option_button.draw
            end
        end
    end

    def show
        @visible = true
        @option_buttons.each do |option_button|
            option_button.set_visibility true
        end
    end

    def hide
        @visible = false
        @option_buttons.each do |option_button|
            option_button.set_visibility false
        end
    end

    def is_visible?
        @visible
    end

    def set_prompt(prompt_key)
        @logger.debug "set_prompt: got prompt_key: '#{prompt_key}'"
        if !prompt_key; raise "prompt_key is nil"; end
        if !@dialog_prompts.has_key? prompt_key; raise "prompt_key missing from prompts collection"; end
        @current_prompt_image = @dialog_prompts[prompt_key]
        # assuming the prompt is the longest thing set dialog width based on it
        @width = @current_prompt_image.width + @boarder_width * 2
    end

    def is_clicked?
        intersects && @visible
    end

    def handle_result
        option_index = 0
        @option_buttons.each do |option_button|
            if option_button.is_clicked?
                selected_option = @option_list[option_index]
                @logger.debug "#{selected_option} was selected"
                yield @option_list[option_index]
            end
            option_index += 1
        end
    end

    def set_position(x, y)
        @dialog_x_position = x
        @dialog_y_position = y

        set_content_position
    end

    def set_relative_position(x, y)
        @dialog_x_position = @dialog_x_position + (x - @previous_x)
        @dialog_y_position = @dialog_y_position + (y - @previous_y)
        @previous_x = x
        @previous_y = y

        set_content_position
    end

    private
    def intersects
        @window.mouse_x > @dialog_x_position &&
        @window.mouse_x < @dialog_x_position + @width &&
        @window.mouse_y > @dialog_y_position &&
        @window.mouse_y < @dialog_y_position + @height
    end

    def set_content_position
        cardsDisplayed = 1 # accounts for prompt
        @option_buttons.each do |button|
            button.set_position(
                dialog_content_x_position,
                dialog_content_y_position + @item_spacing * cardsDisplayed + @font.height * cardsDisplayed,
            )
            cardsDisplayed += 1
        end
    end

    def dialog_content_x_position
        @dialog_x_position + @boarder_width
    end

    def dialog_content_y_position
        @dialog_y_position + @boarder_width
    end
end

class AsyncDialog < SimpleDialog
    def initialize(window, background, font, logger, dialog_prompts, button_options)
        super(window, background, font, logger, dialog_prompts, button_options)
    end

    def get_result
        @selected_option
    end

    def reset_result
        @selected_option = nil
    end

    def handle_result
        option_index = 0
        @option_buttons.each do |option_button|
            if option_button.is_clicked?
                selected_option = @option_list[option_index]
                @logger.debug "CardDialog::handle_result: #{selected_option} was selected"
                @selected_option = selected_option
                return true
            end
            option_index += 1
        end
        return false
    end
end

class CardDialog < AsyncDialog
    def initialize(window, background, font, logger, dialog_prompts, button_options)
        super(window, background, font, logger, dialog_prompts, button_options)
    end
end
