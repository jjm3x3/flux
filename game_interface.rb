class GameInterface

  def printKeepers(player, prompt="here are the keepers you have:")
    keepersPrintOut = player.keepers.map do |keeper|
      keeper.to_s
    end
    @output_stream.puts "#{prompt}\n #{keepersPrintOut}"
  end

  def debug(message)
    if @debug
      @output_stream.puts message
    end
  end

  def trace(message)
    if @trace
      @output_stream.puts message
    end
  end

  def information(message)
    @output_stream.puts message
  end

  def displayCards(hand,prompt="Here is your current hand:")
    @output_stream.puts "#{prompt}\n#{indexed_display(hand)}"
  end

  def displayCardsDebug(hand,prompt="Here is your current hand:")
    debug "#{prompt}\n#{indexed_display(hand)}"
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
      displayCards(card_list, "Here are your options")
      whichCard = get_input.to_i
      card_list.delete_at(whichCard)
  end

  def select_a_player(playerList, prompt="Select a player")
    playerNames = indexed_display(playerList)
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

  def indexed_display(list)
    i = 0
    numbering = "   "
    list.map do |card|
      numbering += i.to_s
      numbering += (" " * card.to_s.length) + "   "
      i += 1
    end
    handPrintOut = list.map do |card|
      card.to_s
    end
    return "#{numbering}\n#{handPrintOut}"
  end
end

class CliInterface < GameInterface
  def initialize(debug)
    @output_stream = $stdout
    @input_stream = $stdin
    @debug = debug
  end

end

class TestInterface < GameInterface
  attr_accessor :cardList
  attr_accessor :prompted
  attr_accessor :indexed_output

  def initialize(input, output)
    @input_stream = input
    @output_stream = output
    @debug = true
    @indexed_output = ""
  end

  def displayCards(hand, prompt="Have some cards")
    method(:displayCards).super_method.call(hand, prompt)
    @prompted = true
    @cardList = hand
  end

  def printKeepers(player, prompt="here are some keepers")
    method(:printKeepers).super_method.call(player, prompt)
    @keepers = player.keepers
  end

  def indexed_display(list)
    @prompted = true
    result = method(:indexed_display).super_method.call(list)
    @indexed_output += result
    result
  end

end