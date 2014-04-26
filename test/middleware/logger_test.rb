require File.expand_path(File.dirname(__FILE__) + '/../helper')
require 'stringio'

describe 'logger middleware test' do
  before do
    @msg = 'test logger'
  end

  it 'should create a default logger if log_file is not provided' do
    logger = SP::Logger.new
    env = {}
    logger.call(env)
    env['sp.logger'].wont_be_nil
  end

  it 'should use log_file provided in the config' do
    logger = SP::Logger.new
    strio = StringIO.new
    env = {'sp.config' => {'log_file' => strio}}
    logger.call(env)
    log = env['sp.logger']
    log.info @msg
    strio.string.must_include @msg
  end
end
