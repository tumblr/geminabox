require 'bundler'

RSpec.describe 'using bundler with Geminabox server' do
  let(:server) {
    TestServer.new do |server|
      server.gem 'test', '1.0'
    end
  }

  let(:project) {
    TestProject.new do |project|
      project.source server.url
      project.gem 'test'
    end
  }

  around do |example|
    server.run do
      project.run do
        example.call
      end
    end
  end

  it 'installs the gem test' do
    project.bundle!
    expect(project).to have_gems_installed
  end

  it 'installs the gem test after removing vendor' do
    project.bundle!
    project.delete_vendor!
    expect(project).not_to have_gems_installed
    project.bundle!
    expect(project).to have_gems_installed
  end
end
