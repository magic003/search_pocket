module SP
  class LegacyLinksLoader
    def initialize(app=nil)
      @app = app
    end

    def call(env)
      env['sp.links'] = [] if env['sp.links'].nil?

      logger = env['sp.logger']

      logger.info 'Start loading legacy links'

      links = Link.where({status: 0})
      env['sp.links'].concat(links.all)

      logger.info "#{links.count} legacy links loaded"

      @app.call(env) if @app
    end
  end
end
