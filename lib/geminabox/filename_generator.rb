module Geminabox::FilenameGenerator
  def gem_filename(name, version, platform)
    platform = String(platform)
    name = String(name)
    version = String(version)

    raise ArgumentError, "platform is required" if platform.empty?
    raise ArgumentError, "name is required" if name.empty?
    raise ArgumentError, "version is required" if version.empty?

    platform_for_filename = platform unless platform == "ruby"
    filename_parts = [name, version, platform_for_filename].compact

    "#{filename_parts.join("-")}.gem"
  end

  extend self
end
