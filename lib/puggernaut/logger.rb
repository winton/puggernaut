module Puggernaut
  module Logger
    
    def logger
      Puggernaut::Logger.logger
    end
    
    class <<self

      def logger
        unless @logger
          base = Dir.pwd
          FileUtils.mkdir_p("#{base}/log")
          file = File.open("#{base}/log/puggernaut.log", 'a')
          file.sync = true
          @logger = ::Logger.new(file)
        end
        @logger
      end
    end
  end
end