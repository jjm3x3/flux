
class BaseLogger
  def print_permanents(player)
    prompt="here are the permanents #{player} has:"
    permanentsPrintOut = []
    permanentsPrintOut += player.keepers.map do |keeper|
      keeper.to_s
    end
    permanentsPrintOut += player.creepers.map do |creeper|
      creeper.to_s
    end
    debug "#{prompt}\n #{permanentsPrintOut}"
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

  def warn(message)
    @output_stream.puts message
  end

  def pause
    @input_stream.gets
  end
end

class CliLogger < BaseLogger
  def initialize(debug)
    @output_stream = $stdout
    @input_stream = $stdin
    @debug = debug
  end

end

class TestLogger < BaseLogger
  def initialize(input, output)
    @input_stream = input
    @output_stream = output
    @debug = true
  end
end