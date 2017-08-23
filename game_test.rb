require_relative "game"
require "test/unit"

class TestGame < Test::Unit::TestCase
  
  def test_trade
    oppenent_selection = 0
    input = StringIO.new(oppenent_selection.to_s) # this indicates player 2 i.e. player in position 0
    silentOutput = StringIO.new # inject this into the game to silent output

    # setup game
    game = Game.new(input)

    # create test card 
    tradeHands = Action.new(13, "trade", "rules")
    game.players[0].hand  <<  tradeHands

    #this card indicates the hand that the first player had before the trade 
    indicator = game.players[0].hand[0] 
    
    # get and play the card 
    theCard = game.players[0].hand[game.players[0].hand.length-1]
    theCard.play(game.players[0], game)

    assert_equal indicator, game.opponents[oppenent_selection].hand[0] 
  end
end
