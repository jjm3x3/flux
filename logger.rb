
class BaseLogger
  def debug(message)
    if @debug
      @output_stream.puts message
    end
  end

  def warn(message)
    @output_stream.puts message
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