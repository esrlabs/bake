require 'common/ext/stdout'
require 'stringio'
require 'thread'

module Bake
  module Multithread

    class Jobs

      @@mutex_sempaphore = Mutex.new
      @@running_threads = 0
      @@waiting_threads = 0
      @@cv = ConditionVariable.new

      def self.incThread
        @@mutex_sempaphore.synchronize do
          if @@running_threads >= Bake.options.threads
            @@waiting_threads += 1
            @@cv.wait(@@mutex_sempaphore)
            @@waiting_threads -= 1
            @@running_threads += 1
          else
            @@running_threads += 1
          end
        end
      end
      def self.decThread
        @@mutex_sempaphore.synchronize do
          @@running_threads -= 1
          if @@waiting_threads > 0
            @@cv.signal
          end
        end
      end

      def initialize(jobs, &block)
        nr_of_threads = [Bake.options.threads, jobs.length].min
        @jobs = jobs
        @threads = []
        nr_of_threads.times do
          @threads << ::Thread.new do
            Jobs.incThread()
            block.call(self)
            Jobs.decThread()
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

