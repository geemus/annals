class Annals

  attr_accessor :buffer, :max

  def initialize(max = 20, &block)
    @max = max
    start
  end

  def capture(&block)
    start
    yield
    stop
  end

  def lines
    @buffer.map {|event| "#{event[:file]}:#{event[:line]} #{event[:method]}"}
  end

  def puts
    for line in lines
      puts(line)
    end
  end

  def start
    @buffer = []
    @size   = 0
    Kernel.set_trace_func(
      lambda { |event, file, line, id, binding, classname|
        if event == 'call'
          unshift(:file => file, :line => line, :method => "in #{id}")
        end
      }
    )
  end

  def stop
    Kernel.set_trace_func(lambda {})
    @buffer.shift # remove Annals#stop from buffer
  end

  def unshift(line)
    @buffer.unshift(line)
    if @size == @max
      @buffer.pop
    else
      @size += 1
    end
  end

end