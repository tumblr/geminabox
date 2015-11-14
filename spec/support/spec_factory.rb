class SpecFactory
  def initialize(name, version, platform, deps)
    @name, @version, @platform, @deps = name, version, platform, deps
  end

  def spec
    %{
      Gem::Specification.new do |s|
        s.name              = #{name.inspect}
        s.version           = #{version.inspect}
        s.platform          = #{platform.inspect}
        s.summary           = #{name.inspect}
        s.description       = s.summary + " description"
        s.author            = 'Test'
        s.files             = []
        s.email             = 'fake@fake.fake'
        s.homepage          = 'http://fake.fake/fake'
        s.licenses          = ['MIT']
        #{dependencies}
      end
    }
  end

protected
  attr_reader :name, :version, :platform, :deps

  def dependencies
    deps.collect do |dep, requirement|
      dep = [*dep]
      gem(*dep)
      if requirement
        "s.add_dependency(#{dep.first.to_s.inspect}, #{requirement.inspect})"
      else
        "s.add_dependency(#{dep.first.to_s.inspect})"
      end
    end.join("\n")

  end
end

