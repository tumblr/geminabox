require "pathname"
require "rubygems/package"

# A GemStore should return a path on the local file system where the referenced
# Gem can be found.
class Geminabox::GemStore
  def initialize(path)
    @root_path = Pathname.new(path)
  end

  def get_path(gem_full_name)
    pathname = path(gem_full_name)
    pathname.exist? or
      raise Geminabox::GemNotFound.new("Gem #{gem_full_name} not found")
    pathname.to_s
  end

  def has_gem?(gem_full_name, version = nil, platform = nil)
    path(gem_full_name, version, platform).exist?
  end

  def add(io)
    raise ArgumentError, "Expected IO object" unless io.respond_to? :read
    Tempfile.create('gem', Dir.tmpdir, encoding: 'ascii-8bit') do |tempfile|
      IO.copy_stream(io, tempfile)
      tempfile.close
      gem = Gem::Package.new(tempfile.path)
      file_name = gem.spec.file_name
      IO.copy_stream(tempfile.path, @root_path.join(file_name))
    end
  rescue Gem::Package::FormatError
    raise Geminabox::BadGemfile, "Could not process uploaded gemfile."
  end
protected
  
  def path(*gem_full_name)
    @root_path.join("#{gem_full_name.compact.join('-')}.gem")
  end

end

def Geminabox::GemStore(path)
  if path.respond_to? :get_path
    path
  else
    Geminabox::GemStore.new(path)
  end
end
