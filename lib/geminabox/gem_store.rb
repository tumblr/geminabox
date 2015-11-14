require "pathname"

# A GemStore should return a path on the local file system where the referenced
# Gem can be found.
class Geminabox::GemStore
  def initialize(path)
    @root_path = Pathname.new(path)
  end

  def get_path(gem_name)
    path = @root_path.join("#{gem_name}.gem")
    path.exist? or raise Geminabox::GemNotFound.new("Gem #{gem_name} not found")
    path.to_s
  end
end
