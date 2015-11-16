module Geminabox::FilenameGenerator
  def gem_filename(name, version = nil, platform = 'ruby')
    name = String(name)
    platform = String(platform)
    version = String(version)

    raise ArgumentError, "name is required" if name.empty?
    raise ArgumentError, "platform is required" if platform.empty?

    if version.empty?
      *parts, version = name.split('-')
      name = parts.join('-')
    end

    platform_for_filename = platform unless platform == "ruby"
    filename_parts = [name, version, platform_for_filename].compact

    "#{filename_parts.join("-")}.gem"
  end

  extend self
end
