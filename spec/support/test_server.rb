require 'net/http'
require 'webrick'

class TestServer
  def initialize(&block)
    @fixture_setup = block
  end

  def run
    create_tempdir!
    start_server!
    setup_gems!
    wait_until_booted!
    yield
    cleanup!
  end

  def url
    "http://127.0.0.1:#{@port}"
  end

protected

  def create_tempdir!
    @dir = Pathname.new(Dir.mktmpdir)
  end

  def setup_gems!
    Dir.chdir @dir do
      gemset_factory = GemsetFactory.new("data")
      @fixture_setup.call(gemset_factory)
    end
  end

  def start_server!
    @port = find_available_port
    @thread = Thread.start do
      app = Geminabox::app(@dir.join("data"))
      Rack::Handler::WEBrick.run app, Port: @port, Host: '127.0.0.1'
    end
  end

  def find_available_port
    server = TCPServer.new('127.0.0.1', 0)
    server.addr[1]
  ensure
    server.close if server
  end

  def booted?
    ::Net::HTTP.get_response("127.0.0.1", '/', @port)
    return true
  rescue Errno::ECONNREFUSED, Errno::EBADF
    return false
  end

  def wait_until_booted!
    start_time = Time.now
    loop do
      return if booted?
      raise TimeoutError.new if (Time.now - start_time) > 2
      sleep(0.05)
    end
  end

  def cleanup!
    Thread.kill(@thread)
    FileUtils.remove_entry @dir
  end
end
