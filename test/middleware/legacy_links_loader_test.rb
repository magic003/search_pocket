require File.expand_path('../../helper', __FILE__)

require_models

describe 'legacy links loader test' do
  before do
    Link.dataset.delete
    @loader = SP::LegacyLinksLoader.new
  end

  after do
    Link.dataset.delete
  end

  it 'should return empty if there is no legacy links' do
    env = default_env
    @loader.call(env)

    env['sp.links'].must_be_empty

    links = parsed_test_links()
    @loader.call(env)
    env['sp.links'].must_be_empty
  end

  it 'should return links if there are some legacy links' do
    links = saved_test_links

    env = default_env

    @loader.call(env)
    env['sp.links'].size.must_equal links.size

    link = links[0]
    link.status = 2
    link.save

    env['sp.links'] = []
    @loader.call(env)
    env['sp.links'].size.must_equal links.size-1

  end

  it 'should return correct links when working with retriever' do
    @loader = SP::LegacyLinksLoader.new(SP::PocketLinksRetriever.new)
    
    links = saved_test_links
    l = links[0]
    l.status = 2
    l.save

    env = default_env
    user = default_user
    env['sp.users'] = [user]
    @loader.call(env)

    env['sp.links'].size.must_be :>, links.size-1
  end

  private

  def saved_test_links
    links = test_links()
    links.each do |l|
      l.save
    end

    links
  end

  def parsed_test_links
    links = test_links()
    links.each do |l|
      l.status = 2
      l.save
    end

    links
  end
end
