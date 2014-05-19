require 'net/http'
require 'uri'
require 'json'

module SP
  class PocketLinksRetriever
    def initialize(app=nil)
      @app = app
    end

    def call(env)
      users = env['sp.users']
      env['sp.links'] = []  # default
      if users
        logger = env['sp.logger']
        logger.info 'Start retrieving links...'
        users.each do |u|
          retrieve_links_by_user(u, env)
        end
        logger.info 'Finish retrieving links.'
      end

      @app.call(env) if @app
    end

    private

    def retrieve_links_by_user(user, env)
      logger = env['sp.logger']
      logger.info "Retrieving links for user #{user.name}"

      config = env['sp.config']

      uri = URI('https://getpocket.com/v3/get')
      res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) do |http|
        req = Net::HTTP::Post.new(uri.request_uri,
                                  initheader={'Content-Type' => 'application/json'})
        playload = {'consumer_key' => config['pocket']['client_secret'],
                    'access_token' => user.token,
                    'state' => 'all'
                    }
        playload['since'] = user.since unless user.since.nil?
        req.body = playload.to_json
        http.request(req)
      end

      if res.code.to_i == 200
        json = JSON.parse(res.body)
        links = []
        if json['list'].size > 0
          json['list'].each_value do |item|
            url = item['resolved_url'] || item['given_url']
            if url
              Link.find_or_create({user_id: user.id, item_id: item['item_id']}) do |l|
                l.url = url
                l.given_title = item['given_title'] && item['given_title'].strip
                l.resolved_title = item['resolved_title'] && item['resolved_title'].strip
                l.favorite = item['favorite'].to_i
                l.excerpt = item['excerpt']
                links << l
              end
            end
          end
        end

        env['sp.links'] = links

        user.update({since: json['since']})
        logger.info "#{links.size} links saved"
      else
        logger.error "request failed: #{res.code} #{res['X-Error']}"
      end
    end
  end
end
