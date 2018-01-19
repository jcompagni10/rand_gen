class BinaryMinHeap
  attr_reader :prc, :store

  def initialize
    @store = []
    @prc = Proc.new { |el1, el2| el1[:time] <=> el2[:time] }
  end

  def count
    store.length
  end

  def empty?
    store.empty?
  end

  def extract
    val = store[0]
    if count > 1
      store[0] = store.pop
      self.class.heapify_down(store, 0, &prc)
    else
      store.pop
    end

    val
  end

  def push(val)
    store << val
    self.class.heapify_up(store, self.count - 1, &prc)
  end

  # returns child indexes for a given parent
  def self.child_indices(len, parent_index)
    [2 * parent_index + 1, 2 * parent_index + 2].select do |idx|
      idx < len
    end
  end

  # returns parent index of child
  def self.parent_index(child_index)
    (child_index - 1) / 2
  end

  # maintain valid heap after extraction
  def self.heapify_down(array, parent_idx, len = array.length, &prc)

    l_child_idx, r_child_idx = child_indices(len, parent_idx)

    parent_val = array[parent_idx]

    children = []
    children << array[l_child_idx] if l_child_idx
    children << array[r_child_idx] if r_child_idx

    if children.all? { |child| prc.call(parent_val, child) <= 0 }
      # Leaf or both children_vals <= parent_val. As a convenience,
      # return the modified array.
      return array
    end

    # Choose smaller of two children.
    swap_idx = nil
    if children.length == 1
      swap_idx = l_child_idx
    else
      swap_idx =
        prc.call(children[0], children[1]) == -1 ? l_child_idx : r_child_idx
    end

    array[parent_idx], array[swap_idx] = array[swap_idx], parent_val
    heapify_down(array, swap_idx, len, &prc)
  end

  # maintain valid heap after adding to end of array
  def self.heapify_up(array, child_idx, len = array.length, &prc)

    return if child_idx == 0

    parent_idx = parent_index(child_idx)
    child_val, parent_val = array[child_idx], array[parent_idx]
    if prc.call(child_val, parent_val) >= 0
      # Heap property valid!
      return array
    else
      array[child_idx], array[parent_idx] = parent_val, child_val
      heapify_up(array, parent_idx, len, &prc)
    end
  end
end
