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
    values.each(&:sort!) unless bottom?
    to_a.tap do |array|
      array.reverse!(&:count)
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
end
