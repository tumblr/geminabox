module Geminabox::FilenameGenerator
  def gem_filename(name, version, platform)
    platform_for_filename = platform unless platform == "ruby"
    filename_parts = [name, version, platform_for_filename].compact
    "#{filename_parts.join("-")}.gem"
  end

  extend self
end
