class Geminabox::Hooks
  def initialize
    @watchers = []
  end

  def call(details)
    @watchers.each do |w|
      w.call details
    end
  end

  # Will called back with event like this:
  # {
  #   :path => "/the/full/path/on/disk",
  #   :type => "one of :create/:change/:delete"
  # }
  def observe(obj = nil, method = :call, &block)
    obj, method = block, :call if block_given?
    @watchers << obj.method(method)
  end
end
