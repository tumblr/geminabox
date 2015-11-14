class GemFactory
  include Geminabox::FilenameGenerator

  class Cache
    def initialize(path)
      @path = Pathname.new(path)
      FileUtils.mkdir_p(@path)
    end

    def fetch_to_path(path, *cache_key, &block)
      FileUtils.mkdir_p(File.dirname(path))
      source_path = fetch(*cache_key, &block)
      if File.expand_path(path) != File.expand_path(source_path)
        FileUtils.cp(source_path, path)
      end
    end

    def fetch(*cache_key, &block)
      cache_key_digest = Digest::MD5.hexdigest(Marshal.dump(cache_key))
      cache_path = @path + cache_key_digest
      if File.exist?(cache_path)
        return cache_path
      else
        path = yield
        FileUtils.cp(path, cache_path)
        path
      end
    end
  end

  def self.gem_file(*args)
    new("spec/.tmp/geminabox-fixtures").gem(*args)
  end

  def initialize(path)
    @path = Pathname.new(File.expand_path(path))
    FileUtils.mkdir_p File.dirname(@path)
    @global_cache = Cache.new(File.expand_path("../../.tmp/gem-fixture-cache", __FILE__))
  end

  def gem(name, version = "1.0", platform: "ruby", deps: {})
    path = @path.join(gem_filename(name, version, platform))

    @global_cache.fetch_to_path(path, name, version, platform, deps) do
      build_gem(path, name, version, platform, deps)
    end
  end

  def build_gem(path, name, version, platform, deps)
    dependencies = deps.collect do |dep, requirement|
      dep = [*dep]
      gem(*dep)
      if requirement
        "s.add_dependency(#{dep.first.to_s.inspect}, #{requirement.inspect})"
      else
        "s.add_dependency(#{dep.first.to_s.inspect})"
      end
    end.join("\n")

    spec = %{
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

    Tempfile.open("spec") do |tmpfile|
      tmpfile << spec
      tmpfile.close

      Dir.chdir File.dirname(path) do
        system "gem build #{tmpfile.path}"
      end
    end

    raise "Failed to build gem #{name}" unless File.exist? path
    path
  end
end
