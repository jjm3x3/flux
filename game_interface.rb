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

end

class CliInterface < GameInterface
  def initialize
    @output_stream = $stdout
    @input_stream = $stdin
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

end

class TestInterface < GameInterface
  attr_accessor :cardList

  def initialize(output)
    @output_stream = output
  end

  def displayCards(hand, prompt="Have some cards")
    $stdout.puts "Here is the test interface being called"
    @cardList = hand
  end

  def printKeepers(player)
    method(:printKeepers).super_method.call(player)
    @keepers = player.keepers
  end
end