module SP
  class Indexer
    def initialize(sphinx_cfg, app=nil)
      @cfg = File.expand_path(sphinx_cfg)
      @app = app
    end

    def call(env)
      logger = env['sp.logger']
      logger.info 'Start indexing...'
      output = `(indexer -c #@cfg delta --rotate && sleep 5 && indexer -c #@cfg --merge main delta --rotate) 2>&1`

      if $? == 0
        logger.info output
      else
        logger.error output
      end

      logger.info 'Finish indexing.'
      @app.call(env) if @app
    end
  end
end
