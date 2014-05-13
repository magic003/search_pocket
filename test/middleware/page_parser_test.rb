require File.expand_path('../../helper', __FILE__)

require_models

describe 'page parser test' do
  before do
    Link.dataset.delete
    User.dataset.delete
    @parser = SP::PageParser.new
  end

  after do
    Link.dataset.delete
    User.dataset.delete
  end

  it 'should do nothing if links is empty' do
    env = default_env
    env['sp.links'] = []
    @parser.call(env)
    env['sp.links'].must_be_empty
    Link.count.must_equal 0
  end

  it 'should parse a normal link' do
    env = default_env
    link = test_links[0]
    title = link.given_title
    env['sp.links'] = [link]
    @parser.call(env)
    Link.count.must_equal 1
    link.content.wont_be_nil
    link.status.must_equal 1
    link.given_title.must_equal title
    link.resolved_title.must_be_nil
  end

  it 'should parse for redirection' do
    env = default_env
    link = test_links[1]
    env['sp.links'] = [link]
    @parser.call(env)
    Link.count.must_equal 1
    link.content.wont_be_nil
    link.status.must_equal 1
    link.resolved_title.wont_be_nil
  end

  it 'should not parse if page does not exist' do
    env = default_env
    link = test_links[2]
    env['sp.links'] = [link]
    @parser.call(env)
    Link.count.must_equal 1
    link.content.must_be_nil
    link.status.must_equal -1
    link.resolved_title.must_be_nil
  end

  it 'should not parse if page is not accessible' do
    env = default_env
    link = test_links[3]
    env['sp.links'] = [link]
    @parser.call(env)
    Link.count.must_equal 1
    link.content.must_be_nil
    link.status.must_equal -1
    link.resolved_title.must_be_nil
  end

  it 'should parse a set of links' do
    env = default_env
    links = test_links
    env['sp.links'] = links
    @parser.call(env)
    Link.count.must_equal links.size
    Link.dataset.where({status: 1}).count.must_be :>, 0
  end

  it 'should work with links retriever' do
    env = default_env
    env['sp.users'] = [default_user]
    app = SP::PocketLinksRetriever.new(SP::PageParser.new)
    app.call(env)
    parsed_count = Link.dataset.where({status: 1}).count
    error_count = Link.dataset.where({status: -1}).count
    parsed_count.must_be :>, 0
    Link.count.must_equal parsed_count+error_count
  end
end
