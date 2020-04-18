require "./game.rb"
require "./game_interface.rb"


Shoes.app do 
    @startStack = stack do
        @title = para "Would you like to play?"
        @startGameButton = button "Push me"

    end

    game = Game.new(3, GuiInterface.new(self))

    @game_stack = stack do
        para "Is this all new :thinking:"
        para "The deck has #{game.deck.count} cards remaining"
        para "The discard has #{game.discardPile.size} cards in it"
    end

    @game_stack.hide

    @startGameButton.click do
        @game_stack.show
        @startStack.hide
        # game.run
    end
end
