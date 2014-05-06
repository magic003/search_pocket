require File.expand_path('../../helper', __FILE__)

require_models

describe 'pocket links retriever test' do
  before do
    Link.dataset.delete
    User.dataset.delete
    @retriever = SP::PocketLinksRetriever.new
  end

  after do
    Link.dataset.delete
    User.dataset.delete
  end

  it 'should do nothing without any user' do
    env = {}
    @retriever.call(env)
    env['sp.links'].must_be_empty
  end

  it 'should save links with correct users' do
    env = default_env
    user = default_user
    env['sp.users'] = [user]
    @retriever.call(env)
    links = env['sp.links']
    links.wont_be_nil
    links.wont_be_empty
    links.size.must_equal Link.count
    user.since.wont_be_nil
  end

  it 'should save nothing if no links found since last retrieval' do
    env = default_env
    user = default_user
    env['sp.users'] = [user]
    @retriever.call(env)
    since = user.since

    # retrieve again for latest links
    env = default_env
    env['sp.users'] = [user]
    @retriever.call(env)
    env['sp.links'].must_be_empty
    user.since.must_be :>, since
  end

  it 'should save links if there are new links since last retrieval' do
    env = default_env
    user = default_user
    user.since = since = 1399268958 # some update time from the test account
    env['sp.users'] = [user]
    @retriever.call(env)
    links = env['sp.links']
    links.wont_be_empty
    links.size.must_equal Link.count
    user.since.must_be :>, since.to_s
  end

  it 'should not save duplicated links' do
    env = default_env
    user = default_user
    env['sp.users'] = [user]
    @retriever.call(env)
    count = Link.count

    # reset since and retrieve again
    user.since = nil
    env = default_env
    env['sp.users'] = [user]
    @retriever.call(env)
    Link.count.must_equal count
    env['sp.links'].must_be_empty
    user.since.wont_be_nil
  end
end
