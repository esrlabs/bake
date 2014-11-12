require 'rake'

module Rake

  def self.add_listener(l)
    get_listener() << l
  end

  def self.get_listener
    @listener ||= []
  end

  def self.remove_listener(l)
    get_listener().delete(l)
  end

  def self.notify_listener(symbol, name)
    Rake::get_listener().each do |l|
      if l.respond_to?(symbol)
        l.send(symbol, name)
      end
    end
  end

  class MultiTask
    invoke_prerequisites_original = self.instance_method(:invoke_prerequisites)
    define_method(:invoke_prerequisites) do |task_args, invocation_chain|
      Rake::notify_listener(:before_prerequisites, name)
      invoke_prerequisites_original.bind(self).call(task_args, invocation_chain)
      Rake::notify_listener(:after_prerequisites, name)
      if !needed?
        Rake::notify_listener(:after_execute, name)
      end
    end
  end

  class Task
    invoke_prerequisites_original = self.instance_method(:invoke_prerequisites)
    execute_original = self.instance_method(:execute)

    define_method (:invoke_prerequisites) do |task_args, invocation_chain|
      Rake::notify_listener(:before_prerequisites, name)
      invoke_prerequisites_original.bind(self).call(task_args, invocation_chain)
      Rake::notify_listener(:after_prerequisites, name)
      if !needed?
        Rake::notify_listener(:after_execute, name)
      end
    end

    define_method(:execute) do |args|
      Rake::notify_listener(:before_execute, name)
      execute_original.bind(self).call(args)
      Rake::notify_listener(:after_execute, name)
    end

  end

end

