class SumSum < Hash
  def initialize(*args)
    @parent = args.pop if args[-1].is_a?(self.class)
    @name = args.shift
    @args = args.compact.dup
    @count = 0
    super()
  end
  
  attr_reader :name, :args, :count, :parent
  
  def add(hash, increase_by=1)
    key = hash[name]
    @count = @count + increase_by
    unless bottom?
      self[key] ||= SumSum.new(*args, self)
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
      clear
      array.each{|k, v| self[k] = v }
    end
    self
  end
  
  def root?
    parent.nil?
  end
  
  def bottom?
    name.nil?
  end
  
  def inspect
    bottom? ? "#{count}" : "{#{name}:#{count} #{super.gsub(/^\{|\}$/, "")}}"
  end
  
  def pretty_print(pp)
    return pp.text(" #{count}") if bottom?
    super
  end
  
  def dump
    return count if bottom?
    hash = {}
    each{ |k, v| hash[k] = v.dump }
    root? ? [all_args, hash] : hash
  end
  
  def self.load(data)
    new(*data[0]).tap do |sum_sum|
      sum_sum.add_from_dump(data[1])
    end
  end
  
  def add_from_dump(data, hash={}, level=0)
    data.each do |key, value|
      hash[all_args[level]] = key
      value.is_a?(Hash) ?
        add_from_dump(value, hash, level + 1) :
        add(hash, value)
    end
  end
  
  private
  
  def all_args
    [name] + args
  end
end
