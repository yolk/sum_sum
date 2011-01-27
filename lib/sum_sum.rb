class SumSum < Hash
  def initialize(*args)
    options = args[-1].is_a?(Hash) ? args.pop : {}
    @key, @parent, @level = options[:key], options[:parent], (options[:level] || 0)
    @kind_of_children, @args, @count = args[level], args, 0
    super()
  end
  
  attr_reader :kind_of_children, :key, :args, :count, :parent, :level
  
  def add(hash, increase_by=1)
    @count = @count + increase_by
    unless bottom?
      key = hash[kind_of_children]
      self[key] ||= SumSum.new(*args, :parent => self, :key => key, :level => level + 1)
      self[key].add(hash, increase_by)
    end
    self
  end
  
  def share
    root? ? 1.0 : count/parent.count.to_f
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
