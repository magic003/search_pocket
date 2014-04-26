require 'logger'

module SP
  class Logger
    def initialize(app=nil)
      @app = app
    end

    def call(env)
      unless @logger
        logdev = $stdout
        config = env['sp.config']
        logdev = config['log_file'] if config && config['log_file']
        @logger = ::Logger.new(logdev, 'weekly')
      end
      
      env['sp.logger'] = @logger
      @app.call(env) if @app
    end
  end
end
