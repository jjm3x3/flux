class GameDriver
    def initialize(players, interface)
        @interface = interface
        @game = Game.new(players, interface)
    end

    def run
        loop do
          activePlayer = @game.players[@game.currentPlayer]
          @interface.information "the discard has #{@game.discardPile.length} card(s) in it"
        #   @interface.information "here is the current goal: #{@goal }"
          @interface.information "here are the current rules:#{@game.ruleBase}"
          @interface.information "\n#{activePlayer}'s turn"
          activePlayer.takeTurn
          @game.progress_turn
        end
    end

end