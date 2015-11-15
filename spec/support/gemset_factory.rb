class GemsetFactory
  def initialize(gem_store)
    @gem_store = gem_store
  end

  def gem(*args)
    @gem_store.add(GemFactory.gem(*args))
  end
end
