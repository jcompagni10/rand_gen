require_relative "binary_min_heap"

class RandomGenerator
  attr_reader :output_queue

  #convenience method for instantiating random gen class and running
  def initialize(gen_amt)
    @output_queue = []
    @thread_output = gen_amt / 5
    @running = false
    @thread_queues = Array.new(5) { [] }
  end

  def start
    @running = true
    start_generators
    writer = start_writer
    kill_proccess
    writer.join
  end

  #returns frequency for last hundred outputs
  def get_freq
    #instantiate with values to ensure consistent ordering
    freq = { 1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0 }
    #sum up freqencies of each number
    last_100 = get_last_100
    last_100.each do |item|
      freq[item.to_i] += 1
    end
    # convert to percentage
    freq.each do |key, val|
      #divide by real length to handle case of less than 100 outputs
      freq[key] = val / last_100.length.to_f
    end
    freq
  end

  private 

  def kill_proccess
    @running = false
  end
  
  #helper method to return last 100 outputs
  def get_last_100
    last_100 = []
    lines = File.readlines('./output.txt').reverse[0...100]
    lines.each do |line|
      last_100 << line.chomp.split(", ")[0]
    end
    last_100
  end

  #################
  # Writer Methods #
  #################

  def start_writer
    fill_queues
    setup_heap
    Thread.new do 
      while @running || !@heap.empty?
        ensure_order_and_write
      end
    end
  end

  #creates a Binary Min Heap to ensure ordered output
  def setup_heap
    @heap = BinaryMinHeap.new
    @thread_queues.each do |queue|
      @heap.push(queue.shift)
    end
  end

  # ensure all queues remain filled until the generators are done generating
  # and and the output queue has been emmptied
  def fill_queues 
    while @thread_queues.any?(&:empty?) && (@running || !@output_queue.empty?)
      el = @output_queue.shift
      @thread_queues[el[:thread]] << el
    end
  end

  #uses a minheap to ensure ordered data output before writing to disc
  def ensure_order_and_write
    fill_queues
    unless @heap.empty?
      #extract the minimum element from the heap 
      extracted_el = @heap.extract
      write_to_disk(extracted_el)
      #add the next element from the same thread to the heap
      from_queue = extracted_el[:thread]
      fill_queues
      next_el = @thread_queues[from_queue].shift
      if next_el
        @heap.push(next_el) 
      end
    end
  end

  #write rand val and timestamp to disc
  def write_to_disk(output)
    path = "./output.txt"
    time = output[:time].strftime("%H:%M:%S:%N")
    output_string = output[:value].to_s + ", " +  time + "\n"
    File.open(path, 'a') { |file| file.write(output_string) }
  end

  ###################
  # Generator Methods #
  ####################

  # Creats 5 seperate writer generator threads
  def start_generators
    threads = []
    5.times do |idx|
      thread = Thread.new { contious_generation }
      thread[:id] = idx
      threads << thread
    end
    threads.each(&:join)
  end
  
  #continious generation for each thread until @thread_ouput is reached
  def contious_generation
    @thread_output.times do
      rand_gen
    end
  end

  #genertes numbers in the specifiied proportions 
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

  #handles output random number -- adds to last 100 and output queue 
  def handle_output(val)
    thread_id = nil
    while thread_id.nil?
      thread_id = Thread.current[:id]
    end
    p val
    output = { value: val, thread: thread_id, time: Time.now }
    @output_queue << output
  end

end

# 
if __FILE__ == $0
  File.open('./output.txt', 'w') { |file| file.write("") }
  random_gen = RandomGenerator.new(5000)
  random_gen.start
  p random_gen.get_freq
end