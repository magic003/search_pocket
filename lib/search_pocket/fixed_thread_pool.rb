require 'thread'

module SearchPocket
  # The +FixedThreadPool+ implements a thread pool with fixed number of threads.
  # The number of threads is specified when creating the instance, and doesn't
  # change during the runtime.
  #
  # @example Creates a fixed thread pool, and gets thread from it
  #
  #   thread_pool = FixedThreadPool.new(2)
  #   thread_pool.execute do 
  #     100.times { 10*10 }
  #   end
  #
  class FixedThreadPool
    # The +Worker+ is the essential element of the thread pool. It is the 
    # object that actually executes the job.
    class Worker
      # Creates a worker.
      # 
      # @param [FixedThreadPool] pool which thread pool this worker belongs to
      # @param [Object] job an object which responds to {#call}, can be a block,
      #   a proc or a lambda
      def initialize(pool,job=nil)
        @pool = pool
        @job = job
        @thread = Thread.new do
          while true
            if @job.nil?
              Thread.stop
            else
              begin
                @job.call
              ensure
                done
              end
            end
          end
        end
      end
      
      # Calls this worker to run some code.
      #
      # @param [Object] an object which responds to #call, can be a block,
      #   a proc, or a lambda
      # @yield [] a block containing the code for the job
      def execute(job=nil)
        @job = job || Proc.new
        @thread.run
      end

      private
      # Called after the work is done.
      def done
        @job = nil
        @pool.ready(self)
      end

    end
    # @return [Integer] number of threads
    attr_reader :size
    # Creates a fixed thread pool with +size+ threads.
    #
    # @param [Integer] size number of threads
    def initialize(size)
      @size = size
      # ready workers
      @ready = []
      size.times do 
        @ready << Worker.new(self)
      end
      # busy workers
      @busy = []
      @mutex = Mutex.new
    end
  
    # Executes the code in this thread pool.
    #
    # @yield [nil] the block specified the code to be executed
    # @return [Boolean] True if there is an idle thread to run it,
    #   otherwise false.
    def execute(job=nil)
      @mutex.synchronize do
        w = @ready.pop
        if w.nil?
          false
        else
          @busy << w
          w.execute(job || Proc.new)
          true
        end
      end
    end

    # Notifies the thread pool that the worker is idle.
    #
    # @param [Worker] worker worker to be set as ready
    def ready(worker)
      @mutex.synchronize do 
        @busy.delete(worker)
        @ready << worker
      end
    end

    # Waits for all running jobs to be done.
    def join
      done = false
      until done
        @mutex.synchronize do
          done = @busy.empty?
        end
        sleep 1 unless done
      end
    end
  end
end
