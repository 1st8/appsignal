module Appsignal
  class Hooks
    class << self
      def register(name, hook)
        @hooks ||= {}
        @hooks[name] = hook
      end

      def load_hooks
        @hooks.each do |name, hook|
          hook.try_to_install(name)
        end
      end

      def hooks
        @hooks ||= {}
      end
    end

    class Hook
      def self.register(name, hook=self)
        Appsignal::Hooks.register(name, hook.new)
      end

      def try_to_install(name)
        if dependencies_present? && !installed?
          Appsignal.logger.info("Installing #{name} integration")
          install
          @installed = true
        end
      end

      def installed?
        !! @installed
      end

      def dependencies_present?
        raise NotImplementedError
      end

      def install
        raise NotImplementedError
      end
    end
  end
end

require 'appsignal/hooks/celluloid'
require 'appsignal/hooks/delayed_job'
require 'appsignal/hooks/net_http'
require 'appsignal/hooks/passenger'
require 'appsignal/hooks/puma'
require 'appsignal/hooks/rake'
require 'appsignal/hooks/redis'
require 'appsignal/hooks/resque'
require 'appsignal/hooks/sequel'
require 'appsignal/hooks/sidekiq'
require 'appsignal/hooks/unicorn'
