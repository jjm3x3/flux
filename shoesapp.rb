require "./game.rb"
require "./game_interface.rb"


Shoes.app do 
    @startGameButton = button "Push me" 
    @title = para "Would you like to play?"
    @startGameButton.click do
        @title.replace "Game starting..."
        game = Game.new(3, GuiInterface.new)
        # game.run
    end
end
