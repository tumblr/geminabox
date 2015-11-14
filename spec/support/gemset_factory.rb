class GemsetFactory
  def initialize(path)
    @gem_factory = GemFactory.new(path)
  end

  def gem(*args)
    @gem_factory.gem(*args)
  end
end
