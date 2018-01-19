require_relative "binary_min_heap"
# require "byebug"

class RandomGenerator
  attr_reader :output_queue

  def initialize(gen_amt)
    File.open('./output.txt', 'w') { |file| file.write("") }
    @output_queue = []
    @last100 = []
    @thread_output = gen_amt / 5
    @running = false
    @thread_queues = Array.new(5) { [] }
  end

  def start
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
      while @running || !@heap.empty?
        ensure_order_and_write
        # write_to_disk(@output_queue.shift) unless output_queue.empty?
      end
    end
  end

  def start_generators
    threads = []
    5.times do |idx|
      thread = Thread.new { contious_generation }
      thread[:id] = idx
      threads << thread
    end
    threads.each(&:join)
  end

  # def ensure_order_and_write
  #   return if @running && @output_queue.length < 40
  #   batch = @output_queue.shift(40)
  #   batch.sort_by! { |output| output[:time] }
  #   batch[0..20].each { |output| write_to_disk(output) }
  #   @output_queue.unshift(*batch[21..40])
  # end

  def fill_queues 
    while @thread_queues.any?(&:empty?) && (@running || !@output_queue.empty?)
      el = @output_queue.shift
      if el && el[:thread]
        @thread_queues[el[:thread]] << el
      end
    end
  end

  def ensure_order_and_write
    fill_queues
    setup_heap if @heap.nil?
    unless @heap.empty?
      extracted_el = @heap.extract
      write_to_disk(extracted_el)
      from_queue = extracted_el[:thread]
      fill_queues
      next_el = @thread_queues[from_queue].shift
      if next_el
        @heap.push(next_el) 
      end
    end
  end

  def setup_heap
    @heap = BinaryMinHeap.new
    @thread_queues.each do |queue|
      @heap.push(queue.shift)
    end
  end
  
  def contious_generation
    count = 0 
    @thread_output.times do
      count += 1   
      rand_gen
    end
  end

  def add_to_queue(output)
    @output_queue << output
  end

  def write_to_disk(output)
    path = "./output.txt"
    time = output[:time].strftime("%H:%M:%S:%N")
    output_string = output[:value].to_s + ", " + output[:thread].to_s + ", " + time + "\n"
    File.open(path, 'a') { |file| file.write(output_string) }
  end

  def handle_output(val)
    @last100 << val
    @last100.shift if @last100.length > 100
    thread_id = Thread.current[:id]
    p thread_id.to_s + ": " + val.to_s
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




# test 

rg = RandomGenerator.new(1000)
rg.start
puts rg.get_freq