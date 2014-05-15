module SP
  class Builder
    def initialize(&block)
      @middlewares = []
      instance_eval &block if block_given?
    end

    def use(klass, *args, &block)
      @middlewares << Proc.new { |app| klass.new(*args, app, &block) }
    end

    def call(env)
      app.call(env) if app
    end

    private

    def app
      @app ||= to_app
    end

    def to_app
      @middlewares.reverse.reduce(nil) { |memo, obj| obj.call(memo) }
    end
  end
end
