class TestProject
  Error = Class.new(RuntimeError)
  def initialize(&block)
    @setup_proc = block
  end

  def run
    setup!
    yield
    cleanup!
  end

  def bundle!
    Bundler.with_clean_env do
      Dir.chdir @dir do
        output = IO.popen(bundler_command, err: [:child, :out]){|io|
          io.read
        }
        raise Error.new(output) unless $?.exitstatus.zero?
      end
    end
  end

  def delete_vendor!
    FileUtils.remove_entry @dir.join("vendor")
  end

  def has_gems_installed?
    Bundler.with_clean_env do
      Dir.chdir @dir do
        system("bundle check")
        return $? == 0
      end
    end
  end

protected
  def setup!
    @dir = Pathname.new(Dir.mktmpdir)
    Dir.chdir @dir do
      TestProjectGemfileBuilder.call(&@setup_proc)
    end
  end

  def cleanup!
    FileUtils.remove_entry @dir
  end

  def bundler_command
    ['bundle', 'install', '--path', 'vendor']
  end
end
