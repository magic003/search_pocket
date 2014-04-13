require 'yaml'

module SP
  class Config
    def initialize(file, app=nil)
      @cfg = YAML.load(File.open(file))
      @app = app
    end

    def call(env)
      env['sp.config'] = @cfg[env['SP_ENV'] || 'development']
      @app.call(env) if @app
    end
  end
end
