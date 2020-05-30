class GameCli
  def initialize(game, logger, new_game_driver)
      @logger = logger
      @game = game
      @new_game_driver = new_game_driver
      @interface = TrueCliInterface.new
  end

  def run
      loop do
        activePlayer = @new_game_driver.await.active_player.value
        @interface.display_game_state(@game)
        @logger.information "\n#{activePlayer}'s turn"

        @new_game_driver.await.setup_new_turn
        hand = activePlayer.hand
        cardsPlayed = 0
        while !@new_game_driver.await.turn_over?.value
          print_permanents(activePlayer, prompt="here are the permanents you have:")

          cardToPlay = @interface.await.choose_from_list(hand, "Select a card from your hand to play").value
          @logger.debug "Card selected is: '#{cardToPlay}'"

          play_result = @new_game_driver.await.post_card_play_clean_up(activePlayer, cardToPlay)
          @logger.debug "What was the play result? '#{play_result.state}'"
          cardsPlayed += 1

          hand = activePlayer.hand # really a sad sideeffect of much statefull programming
          @logger.information "played: #{cardsPlayed} of play: #{@game.ruleBase.playRule}"
        end
      end
  end

  private
  def print_permanents(player, prompt="here are the permanents you have:")

    permanentsPrintOut = []
    permanentsPrintOut += player.keepers.map do |keeper|
      keeper.to_s
    end
    permanentsPrintOut += player.creepers.map do |creeper|
      creeper.to_s
    end
    @logger.information "#{prompt}\n #{permanentsPrintOut}"
  end

end