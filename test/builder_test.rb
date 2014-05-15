require File.expand_path('../helper', __FILE__)

class Times
  def initialize(times, app=nil)
    @times = times
    @app = app
  end

  def call(env)
    env['v'] *= @times
    @app.call(env) if @app
  end
end

class Half
  def initialize(app=nil)
    @app = app
  end

  def call(env)
    env['v'] /= 2
    @app.call(env) if @app
  end
end

describe 'test builder' do
  it 'should not throw exception if there is no middleware' do
    builder = SP::Builder.new
    builder.call({})
  end

  it 'should invoke middlewares in the right order' do
    builder = SP::Builder.new do
      use Times, 3
      use Half
    end
    env = {'v' => 3}
    builder.call(env)
    env['v'].must_equal 4

    builder = SP::Builder.new do
      use Half
      use Times, 3
    end
    env = {'v' => 3}
    builder.call(env)
    env['v'].must_equal 3
  end
end
