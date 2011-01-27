# = SumSum
#
# SumSum allows you to generate simple reports on the count of values in hashes.
class SumSum < Hash
  # @overload initialize(*keys, options = {})
  #   @param [Symbol,String] *args the keys to anaylze on hashes
  #   @param [Hash] options are only used internaly
  #
  # @example Create a SumSum to analyze hashes with attributes :gender, :age and :name
  #   SumSum.new(:gender, :age, :name)
  def initialize(*args)
    options = args[-1].is_a?(Hash) ? args.pop : {}
    @key, @parent, @level = options[:key], options[:parent], (options[:level] || 0)
    @kind_of_children, @args, @count = args[level], args, 0
    super()
  end

  attr_reader :kind_of_children, :key, :args, :count, :parent, :level

  # Add a new hash to analyze.
  #
  # @param [Hash,#[]] hash the data to add to the SumSum instance
  # @param [Integer] increase_count_by amount to add to count
  # @return [SumSum] Returns itself
  #
  # @example Add some data
  #   sum_sum.add(:gender => "W", :age => 23, :name => "Nina")
  #   sum_sum.add(:gender => "M", :age => 77, :name => "Carl")
  #   sum_sum.add(:gender => "W", :age => 33, :name => "Nora")
  def add(hash, increase_count_by=1)
    @count = @count + increase_count_by
    unless bottom?
      key = hash[kind_of_children]
      self[key] ||= SumSum.new(*args, :parent => self, :key => key, :level => level + 1)
      self[key].add(hash, increase_count_by)
    end
    self
  end

  # Returns share compared to parent
  #
  # @return [Float] Returns the share between 0.0 and 1.0
  #
  # @example Get share of all (returns alway 1.0)
  #   sum_sum.share
  #   => 1.0
  # @example Get share of all women compared to all entries (two out of three)
  #   sum_sum["W"].share
  #   => 0.75
  # @example Get share of all women with age 23 compared to all women entries (one out of two)
  #   sum_sum["W"][23].share
  #   => 0.5
  def share
    root? ? 1.0 : count/parent.count.to_f
  end

  # Returns share compared to all entries
  #
  # @return [Float] Returns the share between 0.0 and 1.0
  #
  # @example Get share of all (returns alway 1.0)
  #   sum_sum.total_share
  #   => 1.0
  # @example Get share of all women compared to all entries (two out of three)
  #   sum_sum["W"].total_share
  #   => 0.75
  # @example Get share of all women with age 23 compared to all entries (one out of three)
  #   sum_sum["W"][23].total_share
  #   => 0.3333333
  def total_share
    count/root.count.to_f
  end

  def sort!
    return self if bottom?
    values.each(&:sort!)
    to_a.sort_by{|it| it[1].count}.reverse.tap do |array|
      clear && array.each{|k, v| self[k] = v }
    end
    self
  end

  def root?
    !parent
  end

  def bottom?
    !kind_of_children
  end

  def root
    root? ? self : parent.root
  end

  def inspect
    bottom? ? "#{count}" : "{#{kind_of_children}:#{count} #{super.gsub(/^\{|\}$/, "")}}"
  end

  def pretty_print(pp)
    return pp.text(" #{count}") if bottom?
    super
  end

  def dump
    return count if bottom?
    hash = {}
    each{ |k, v| hash[k] = v.dump }
    root? ? [args, hash] : hash
  end

  def self.load(data)
    new(*data[0]).tap do |sum_sum|
      sum_sum.add_from_dump(data[1])
    end
  end

  def add_from_dump(data, hash={}, on_level=0)
    data.each do |k, v|
      hash[args[on_level]] = k
      v.is_a?(Hash) ?
        add_from_dump(v, hash, on_level + 1) :
        add(hash, v)
    end
  end

end
