require "rubygems"
gem "bundler"
require "bundler/setup"

require_relative '../lib/geminabox'
require 'minitest/autorun'
require 'fileutils'
require 'test_support/gem_factory'
require 'test_support/geminabox_test_case'
require 'test_support/http_dummy'
require 'test_support/http_socket_error_dummy'

require 'capybara/mechanize'
require 'capybara/dsl'

require 'webmock/minitest'
WebMock.disable_net_connect!(:allow_localhost => true)

Capybara.default_driver = :mechanize
Capybara.app_host = "http://localhost"
module TestMethodMagic
  def test(test_name, &block)
    define_method "test_method: #{test_name} ", &block
  end
end



class Minitest::Test
  extend TestMethodMagic

  def self.localhost_certificate_installed?
    c = OpenSSL::X509::Certificate.new(File.read(fixture("localhost.crt")))
    OpenSSL::SSL::SSLContext::DEFAULT_CERT_STORE.verify(c)
  end

  def self.check_ssl_certificate_setup!
    if localhost_certificate_installed?
      true
    else
      warn "You need to install the test certificate into your openssl certificate list."
      warn "SSL based test will not work without it"
      if RUBY_PLATFORM.include? "darwin"
        warn "In OS-X with homebrew, add #{fixture("localhost.crt")} to your system keychain."
        warn "You can then use https://github.com/raggi/openssl-osx-ca to keep openssl in sync"
      else
        warn "Try adding #{fixture("localhost.crt")} to your system certs."
        warn "You cna usually do this with:"
        want %{   cat test/fixtures/localhost.crt >> "$( openssl version -d | awk -F'"' '{print $2}' )/cert.pem"}
      end
      false
    end
  end

  TEST_DATA_DIR="/tmp/geminabox-test-data"
  def clean_data_dir
    FileUtils.rm_rf(TEST_DATA_DIR)
    FileUtils.mkdir(TEST_DATA_DIR)
    Geminabox.data = TEST_DATA_DIR
  end

  def self.fixture(path)
    File.join(File.expand_path("../fixtures", __FILE__), path)
  end

  def fixture(*args)
    self.class.fixture(*args)
  end


  def silence_stream(stream)
    old_stream = stream.dup
    stream.reopen('/dev/null')
    stream.sync = true
    yield
  ensure
    stream.reopen(old_stream)
  end

  def silence
    silence_stream(STDERR) do
      silence_stream(STDOUT) do
        yield
      end
    end
  end

  def inject_gems(&block)
    silence do
      yield GemFactory.new(File.join(Geminabox.data, "gems"))
      Gem::Indexer.new(Geminabox.data).generate_index
    end
  end

end

