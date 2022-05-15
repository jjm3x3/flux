require 'concurrent'
require "./direction.rb"


class StringFormattingUtilities
  def self.indexed_display(list)
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

class BaseTextInterface
  include Concurrent::Async

  def initialize(prompts)
    super()
    @prompts = {
      default: "Some default prompt",
      play_first_prompt: "Which one would you like to play first?",
      select_a_card_to_play_prompt: "Select a card from your hand to play"
    }
    @prompts = @prompts.merge(prompts)
  end

  def choose_from_list(card_list, prompt="Choose an option")
    if prompt.is_a?(String)
      @output_stream.puts prompt
    else # assumed to be symbol
      if !@prompts.has_key? prompt; raise "prompt_key missing from prompts collection"; end
      @output_stream.puts @prompts[prompt]
    end
    @output_stream.puts StringFormattingUtilities.indexed_display(card_list)
    whichCard = get_input.to_i
    card_list.delete_at(whichCard)
  end

  def ask_yes_no(prompt)
    @output_stream.puts "#{prompt} (y/N)"
    response = get_input
    response == 'y' || response == 'Y'
  end

  def ask_rotation(prompt="Which direction?")
    @output_stream.puts "#{prompt} (clockwise/CounterClockwise)"
    response = get_input
    response.start_with?("cl") ? Direction::Clockwise : Direction::CounterClockwise
  end

  private
  def get_input
    input = @input_stream.gets
    input.strip
  end
end

class CliInterface < BaseTextInterface

  def initialize(prompts={})
    super(prompts)
    @output_stream = $stdout
    @input_stream = $stdin
  end

  def display_game_state(game)
    @output_stream.puts "\e[2J\e[f"
    @output_stream.puts "The deck has #{game.deck.count} cards in it"
    @output_stream.puts "the discard has #{game.discardPile.length} card(s) in it"
    @output_stream.puts "here is the current goal: #{game.goal}"
    @output_stream.puts "here are the current rules:#{game.ruleBase}"
  end
end

class TestInterface < BaseTextInterface

  attr_reader :card_list
  attr_reader :prompted

  def initialize(input, output, prompts={})
    super(prompts)
    @input_stream = input
    @output_stream = output
  end

  def choose_from_list(card_list, prompt)
    @prompted = true
    @card_list = card_list
    method(:choose_from_list).super_method.call(card_list, prompt)
  end
end
