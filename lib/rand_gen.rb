require "byebug"
class RandomGenerator
  attr_reader :output_queue

  def initialize
    @output_queue = []
    @last100 = []
    @running = true
    writer = start_writer
    start_generators
    kill_proccess
    writer.join
  end

  def kill_proccess
    @running = false
  end
  
  def get_freq
    #instatiate with values to ensure consistent ordering
    freq = { 1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0 }
    @last100.each do |item|
      freq[item] += 1
    end
    freq.each do |key, val|
      freq[key] = val / @last100.length.to_f
    end
    freq
  end

  def start_writer
    Thread.new do 
      while @running || !output_queue.empty?
        ensure_order_and_write
      end
    end
  end

  def start_generators
    threads = []
    5.times do 
      threads << Thread.new { contious_generation }
    end
    threads.each(&:join)
  end

  def ensure_order_and_write
    batch = @output_queue.shift(5)
    batch.sort_by!{|output| output[:time]}
    batch.each { |output| write_to_disk(output) }
  end
  
  def contious_generation
    count = 0 
    100.times do
      count += 1   
      rand_gen
    end
  end

  def add_to_queue(output)
    @output_queue << output
  end

  def write_to_disk(output)
    path = "./output.txt"
    output_string = output[:value].to_s + ", " + output[:thread].to_s + ", " + output[:time].to_s + "\n"
    File.open(path, 'a') { |file| file.write(output_string) }
  end

  def handle_output(val)
    @last100 << val
    @last100.shift if @last100.length > 100
    thread_id = Thread.current
    # p thread_id.to_s + ": " + val.to_s
    output = { value: val, thread: thread_id, time: Time.now }
    add_to_queue(output)
  end

  def rand_gen
    rand100 = rand(1..100)
    if (0..50).cover?(rand100)
      output_val =  1
    elsif (51..75).cover?(rand100)
      output_val =  2
    elsif (76..90).cover?(rand100)
      output_val = 3
    elsif (91..95).cover?(rand100)
      output_val =  4
    elsif (96..100).cover?(rand100)
      output_val =  5
    end
    handle_output(output_val)
  end
end


#test 
rg = RandomGenerator.new
puts rg.get_freq