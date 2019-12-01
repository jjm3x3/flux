class GameInterface

  def printKeepers(player)
    keepersPrintOut = player.keepers.map do |keeper|
      keeper.to_s
    end
    @output_stream.puts "here are the keepers you have:\n #{keepersPrintOut}"
  end

  def debug(message)
    @output_stream.puts message
  end

  def information(message)
    @output_stream.puts message
  end

  def displayCards(hand,prompt="Here is your current hand:")
    i = 0
    numbering = "   "
    hand.map do |card|
      numbering += i.to_s
      numbering += (" " * card.to_s.length) + "   "
      i += 1
    end
    handPrintOut = hand.map do |card|
      card.to_s
    end
    @output_stream.puts "#{prompt}\n#{numbering}\n#{handPrintOut}"
  end

  def ask_yes_no(prompt)
    @output_stream.puts "#{prompt} (y/N)"
    response = get_input
    response == 'y' || response == 'Y'
  end

  def ask_rotation(prompt="Which direction?")
    information "#{prompt} (clockwise/CounterClockwise)"
    response = get_input
    response.start_with?("cl") ? :clockwise : :counterClockwise
  end

  def isClockwise(direction)
    direction == :clockwise
  end

  def select_a_card(card_list, prompt="Select a card")
      information prompt
      displayCards(card_list)
      whichCard = get_input.to_i
      card_list.delete_at(whichCard)
  end

  def select_a_player(playerList, prompt="Select a player")
    playerNames = playerList.map do |player|
      player.to_s
    end
    information prompt
    information "#{playerNames}"
    whichPlayer = get_input.to_i
    playerList[whichPlayer]
  end

  private
  def get_input
    input = @input_stream.gets
    input.strip
  end
end

class CliInterface < GameInterface
  def initialize
    @output_stream = $stdout
    @input_stream = $stdin
  end

end

class TestInterface < GameInterface
  attr_accessor :cardList

  def initialize(input, output)
    @input_stream = input
    @output_stream = output
  end

  def displayCards(hand, prompt="Have some cards")
    method(:displayCards).super_method.call(hand, prompt)
    @cardList = hand
  end

  def printKeepers(player)
    method(:printKeepers).super_method.call(player)
    @keepers = player.keepers
  end

end