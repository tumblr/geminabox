class BundlerOutputParser
  def initialize(bundler_output)
    @gems = bundler_output.lines.grep(/^\s+\*/).map{|l|
      match = %r{\s+\*\s+([^\s]+)\s+\(([^\)]+)\)}.match(l)
      {
        name: match[1],
        version: match[2],
      }
    }
  end

  def has?(name, version)
    @gems.include?(name: name, version: version)
  end
end
