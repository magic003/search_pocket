require File.expand_path('../../helper', __FILE__)

require 'fileutils'

require_models

describe 'test indexer' do
  SPHINX_CFG = File.expand_path('../../fixtures/sphinx.conf', __FILE__)
  DATA_DIR = '/tmp/data'

  before do
    Dir.mkdir(DATA_DIR) unless File.exists?(DATA_DIR)
    `indexer -c #{SPHINX_CFG} main`
    `searchd -c #{SPHINX_CFG}`
    @indexer = SP::Indexer.new(SPHINX_CFG)
    Link.dataset.delete
  end

  after do
    Link.dataset.delete
    `searchd -c #{SPHINX_CFG} --stopwait`
    FileUtils.rm_r DATA_DIR
  end
  
  it 'should create index if there is no link' do
    env = default_env
    @indexer.call(env)

    Link.count.must_equal 0
    File.exists?(DATA_DIR + '/main.sph').must_equal true
    File.exists?(DATA_DIR + '/delta.sph').must_equal true
  end

  it 'should create index for a set of links' do
    env = default_env
    env['sp.links'] = test_links[0,3]
    SP::PageParser.new.call(env)
    @indexer.call(env)

    File.exists?(DATA_DIR + '/main.sph').must_equal true
    File.exists?(DATA_DIR + '/delta.sph').must_equal true
    Link.dataset.where({status: 2}).count.must_equal 2
  end
end
