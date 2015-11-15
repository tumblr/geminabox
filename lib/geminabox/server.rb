require 'sinatra'
require 'geminabox/gem_store'

class Geminabox::Server < Sinatra::Base
  attr_reader :gem_store
  def initialize(gem_store)
    super()
    @gem_store = Geminabox::GemStore(gem_store)
  end

  get'/' do
    "*shrug*"
  end

  get '/api/v1/dependencies' do
    Marshal.dump([
      {
        name: 'test',
        number: '1.0',
        platform: 'ruby',
        dependencies: [],
      },
    ])
  end

  get '/gems/:file.gem' do
    send_file gem_store.get_path(params[:file])
  end

  get '/*' do
    p env
  end
end
