require "./game.rb"
require "./game_interface.rb"


Shoes.app do 
    @startStack = stack do
        @title = para "Would you like to play?"
        @startGameButton = button "Push me"

    end

    @game_stack = stack do
        para "Is this all new :thinking:"
    end

    @game_stack.hide

    @startGameButton.click do
        @game_stack.show
        @startStack.hide
        game = Game.new(3, GuiInterface.new(self))
        # game.run
    end
end
