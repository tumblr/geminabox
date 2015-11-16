require "geminabox/filename_generator"

class Geminabox::IndexedGem
  include Geminabox::FilenameGenerator
  attr_reader :name, :version, :platform

  def initialize(name, version, platform)
    @name, @version, @platform = String(name), String(version), String(platform)
    if [@name, @version, @platform].any?(&:empty?)
      raise ArgumentError, "name, version and platform are all required"
    end
  end

  def to_s
    gem_filename(name, version, platform)
  end

  def == other
    if other.class != self.class
      raise ArgumentError, "Can't compare #{self.inspect} with #{other.inspect}"
    end
    [name, version, platform] == [other.name, other.version, other.platform]
  end

  def hash
    [name, version, platform].hash
  end
end
