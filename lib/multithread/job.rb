require 'common/ext/stdout'
require 'stringio'
require 'thread'

module Bake
  module Multithread

    class Jobs
      def initialize(jobs, &block)
        nr_of_threads = [Bake.options.threads, jobs.length].min
        @jobs = jobs
        @threads = []
        nr_of_threads.times do
          @threads << ::Thread.new do
            block.call(self)
          end
        end
      end

      def failed
        @failed ||= false
      end
      def set_failed
        @failed = true
      end

      def get_next_or_nil
        the_next = nil
        mutex.synchronize {
          the_next = @jobs.shift
        }
        the_next
      end
      def join
        @threads.each{|t| while not t.join(2) do end}
      end
      def mutex
        @mutex ||= Mutex.new
      end
    end

  end
end

