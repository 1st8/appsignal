module Appsignal
  class Hooks
    class PumaHook < Appsignal::Hooks::Hook
      register :puma

      def dependencies_present?
        defined?(::Puma) &&
          ::Puma.respond_to?(:cli_config) &&
          ::Puma.cli_config
      end

      def install
        ::Puma.cli_config.options[:before_worker_boot] ||= []
        ::Puma.cli_config.options[:before_worker_boot] << Proc.new do |id|
          Appsignal.forked
        end

        ::Puma.cli_config.options[:before_worker_shutdown] ||= []
        ::Puma.cli_config.options[:before_worker_shutdown] << Proc.new do |id|
          Appsignal.stop
        end

        ::Puma::Cluster.class_eval do
          alias stop_workers_without_appsignal stop_workers

          def stop_workers
            Appsignal.stop
            stop_workers_without_appsignal
          end
        end
      end
    end
  end
end
