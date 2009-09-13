module Astrails
  module Safe
    class Rcloud < Sink

      protected

      def active?
        container && username && api_key
      end

      def path
        @path ||= expand(config[:rcloud, :path] || config[:local, :path] || ":kind/:id")
      end

      def save
        raise RuntimeError, "pipe-streaming not supported for Rackspace Cloudfiles." unless @backup.path

        # needed in cleanup even on dry run
        rcf = CloudFiles::Connection.new(username, api_key)

        puts "Uploading #{container}:#{full_path}" if $_VERBOSE || $DRY_RUN
        unless $DRY_RUN || $LOCAL
          benchmark = Benchmark.realtime do
            if rcf.container_exists?(container)
              rcont = rcf.container(container)
            else
              rcont = rcf.create_container(container)
            end
            rfile = rcont.create_object(full_path)
            rfile.load_from_filename(@backup.path)
          end
          puts "...done" if $_VERBOSE
          puts("Upload took " + sprintf("%.2f", benchmark) + " second(s).") if $_VERBOSE
        end
      end

      def cleanup
        return if $LOCAL

        return unless keep = @config[:keep, :rcloud]
        
        rcf = CloudFiles::Connection.new(username, api_key)
        rcont = rcf.container(container)

        puts "listing files: #{container}:#{base}*" if $_VERBOSE
        rfiles = rcont.objects_detail(:prefix => base)
        puts rfiles.collect {|x| x[0]} if $_VERBOSE

        files = rfiles.
          collect {|x| x[0]}.
          sort

        cleanup_with_limit(files, keep) do |f|
          puts "removing Rackspace Cloudfile #{container}:#{f}" if $DRY_RUN || $_VERBOSE
          rcont.delete_object(f) unless $DRY_RUN || $LOCAL
        end
      end

      def container
        @config[:rcloud, :container]
      end

      def username
        @config[:rcloud, :username]
      end

      def api_key
        @config[:rcloud, :api_key]
      end

    end
  end
end
