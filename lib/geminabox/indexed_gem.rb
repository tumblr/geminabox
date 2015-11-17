require "geminabox/filename_generator"

class Geminabox::IndexedGem
  include Geminabox::FilenameGenerator
  attr_reader :name, :version, :platform, :dependencies

  def initialize(name, version, platform, dependencies = {})
    @name, @version, @platform = String(name), String(version), String(platform)
    @dependencies = dependencies.to_a
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

  def to_hash
    {
      name: name,
      number: version,
      platform: platform,
      dependencies: dependencies,
    }
  end
end
