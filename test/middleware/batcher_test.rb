require File.expand_path('../../helper', __FILE__)

class BatchCounter 
  attr_accessor :count, :links

  def initialize
    @count = 0
    @links = 0
  end

  def call(env)
    @count += 1
    @links += env['sp.links'].size
  end
end

describe 'batcher test' do

  it 'should run once if batch_size is less or equal than 0' do
    env = default_env
    counter = BatchCounter.new
    batcher = SP::Batcher.new(0, counter)

    env['sp.links'] = Array.new(1)
    batcher.call(env)
    counter.count.must_equal 1
    counter.links.must_equal 1

    env['sp.links'] = Array.new(10)
    reset_counter(counter)
    batcher.call(env)
    counter.count.must_equal 1
    counter.links.must_equal 10

    reset_counter(counter)
    batcher = SP::Batcher.new(-1, counter)
    batcher.call(env)
    counter.count.must_equal 1
    counter.links.must_equal 10
  end

  it 'should not run if links is empty' do
    env = default_env
    env['sp.links'] = []

    counter = BatchCounter.new
    batcher = SP::Batcher.new(0, counter)
    batcher.call(env)
    counter.count.must_equal 0
    counter.links.must_equal 0

    batcher = SP::Batcher.new(2, counter)
    batcher.call(env)
    counter.count.must_equal 0
    counter.links.must_equal 0
  end

  it 'should run correct batches' do
    env = default_env
    counter = BatchCounter.new
    batcher = SP::Batcher.new(3, counter)

    env['sp.links'] = Array.new(9)
    batcher.call(env)
    counter.count.must_equal 3
    counter.links.must_equal 9

    reset_counter(counter)
    env['sp.links'] = Array.new(2)
    batcher.call(env)
    counter.count.must_equal 1
    counter.links.must_equal 2

    reset_counter(counter)
    env['sp.links'] = Array.new(10)
    batcher.call(env)
    counter.count.must_equal 4
    counter.links.must_equal 10
  end

  private

  def reset_counter(counter)
    counter.count = 0
    counter.links = 0
  end
end
