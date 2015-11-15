class GemFactory
  include Geminabox::FilenameGenerator

  class Cache
    def initialize(path)
      @path = Pathname.new(path)
      FileUtils.mkdir_p(@path)
    end

    def fetch(*cache_key, &block)
      cache_key_digest = Digest::MD5.hexdigest(Marshal.dump(cache_key))
      cache_path = @path + cache_key_digest
      if not File.exist?(cache_path)
        io = yield
        IO.copy_stream(io, cache_path)
      end
      return File.open(cache_path, encoding: 'ascii-8bit')
    end
  end

  def self.gem(*args)
    new.gem(*args)
  end

  def initialize
    @global_cache = Cache.new(File.expand_path("../../.tmp/gem-fixture-cache", __FILE__))
  end

  def gem(name, version = "1.0", platform: "ruby", deps: {})
    @global_cache.fetch(name, version, platform, deps) do
      build_gem(name, version, platform, deps)
    end
  end

  def build_gem(name, version, platform, deps)
    filename = gem_filename(name, version, platform)
    spec = SpecFactory.new(name, version, platform, deps).spec

    Tempfile.open("spec") do |tmpfile|
      tmpfile << spec
      tmpfile.close
      Dir.mktmpdir do |dir|
        Dir.chdir(dir) do
          system "gem build #{tmpfile.path}"
          raise "Failed to build gem #{name}" unless File.exist? filename
          return File.open(filename, encoding: 'ascii-8bit')
        end
      end
    end
  end
end
