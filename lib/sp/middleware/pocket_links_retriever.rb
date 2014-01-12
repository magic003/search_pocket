module SP
  class PocketLinksRetriever
    def initialize(app, consumer_key)
      @app = app
      @consumer_key = consumer_key
    end

    def call(env)
      user = env['sp.user']
      if user

      end
    end
  end
end
