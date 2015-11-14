class TestProjectGemfileBuilder
  def self.call(&block)
    instance = new
    block.call(instance)
    instance.write!
  end

  def initialize
    @gems = []
    @sources = []
  end

  def source(source)
    @sources << source
  end

  def gem(name)
    @gems << [name]
  end

  def write!
    File.open("Gemfile", 'w') do |f|
      @sources.each do |source|
        f.puts "source #{source.to_s.inspect}"
      end

      @gems.each do |(gem)|
        f.puts "gem #{gem.inspect}"
      end
    end
  end
end
