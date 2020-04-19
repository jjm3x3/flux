class GameDriver
  def initialize(players, logger)
      @logger = logger
      @game = Game.new(players, logger)
      @interface = TrueCliInterface.new
  end

  def run
      loop do
        activePlayer = @game.players[@game.currentPlayer]
        @interface.display_game_state(@game)
      #   @interface.information "here is the current goal: #{@goal }"
        @logger.information "\n#{activePlayer}'s turn"
        takeTurn(activePlayer)
        @game.progress_turn
      end
  end

    end

end