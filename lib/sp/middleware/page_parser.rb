require 'timeout'
require 'open-uri'
require 'open_uri_redirections'
require 'readability'

module SP
  class PageParser
    def initialize(app=nil)
      @app = app
      @pool = SP::FixedThreadPool.new(20)
    end

    def call(env)
      logger = env['sp.logger']
      logger.info 'Start parsing links...'

      parse_links(env)

      logger.info 'Finish parsing links.'
    end

    private

    def parse_links(env)
      logger = env['sp.logger']
      links = env['sp.links']
      count = links.size

      links.each do |l|
        wrapper = Proc.new do |link|
          Proc.new do
            begin
              page = timeout(120) do
                f = open(link.url, :allow_redirections => :safe)
                ct = f.content_type
                # only parse text page
                if ct.nil? || ct.start_with?('text/')
                  f.read
                else
                  ''
                end
              end
              # remove the invalid characters and change to utf-8 encoding
              encoding = GuessHtmlEncoding.guess(page)
              page = page.chars.select { |c| c.valid_encoding? }.join
              page.encode!('utf-8', encoding)

              doc = Readability::Document.new(page)
              link.set({content: doc.content, status: 1})
              title = link.given_title || link.resolved_title
              if title.nil? || title.empty?
                link.set({resolved_title: doc.title && doc.title.strip})
              end
              link.save
            rescue Timeout::Error, Errno::ETIMEDOUT, Exception => e
              logger.error "Warning: failed to parse link: #{link.url}"
              logger.error e.to_s
              link.update({status: -1})
            end
          end
        end # end of wrapper

        unless @pool.execute(wrapper[l])
          # redo after 1 second if there is no idle thread
          sleep 1
          redo
        end
      end

      @pool.join
      logger.info "#{count} links parsed."

      @app.call(env) if @app
    end
  end
end
