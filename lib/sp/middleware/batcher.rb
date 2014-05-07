module SP
  class Batcher
    def initialize(batch_size=0, app=nil)
      @batch_size = batch_size
      @app = app
    end

    def call(env)
      logger = env['sp.logger']
      links = env['sp.links']
      total = links.size
      bs = @batch_size > 0 ? @batch_size : total

      logger.info "Process #{total} links in batches of #{bs}..."
      start = 0
      while start < total
        env['sp.links'] = links[start, bs]
        @app.call(env) if @app
        
        start += bs
      end

      logger.info "Finish batching."
    end
  end
end
