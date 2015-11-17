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
    if gems = params["gems"]
      gems = params["gems"].split(",")
      indexed_gems = gems.sort.flat_map{|name|
        gem_store.find_gem_versions(name)
      }
      Marshal.dump(indexed_gems.map(&:to_hash))
    else
      ''
    end
  end

  get '/gems/:file.gem' do
    send_file gem_store.get_path(params[:file])
  end

  get '/*' do
    p env
  end
end
