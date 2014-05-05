require 'test_helper'
if Geminabox::TestCase.check_ssl_certificate_setup!
  class SSLTest < Geminabox::TestCase
    url "https://localhost/"
    ssl true

    should_push_gem
  end
end
