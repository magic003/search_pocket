require File.expand_path(File.dirname(__FILE__) + '/../helper')

describe 'Config middleware test' do
  before do
    file = File.expand_path(File.dirname(__FILE__) + '/../fixtures/config.yml')
    @config = SP::Config.new(file)
  end

  it 'should return development if SP_ENV is not specified' do
    env = {}
    @config.call(env)
    env['sp.config']['name'].must_equal 'development'
  end

  it 'should return production if SP_ENV is production' do
    env = {'SP_ENV' => 'production'}
    @config.call(env)
    env['sp.config']['name'].must_equal 'production'
  end

  it 'should return nil if SP_ENV is incorrect' do
    env = {'SP_ENV' => 'dummy'}
    @config.call(env)
    env['sp.config'].must_be_nil
  end
end
