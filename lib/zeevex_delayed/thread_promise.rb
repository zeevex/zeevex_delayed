require File.expand_path(File.join(File.dirname(__FILE__), 'promise'))
require 'zeevex_proxy'

module ZeevexDelayed
  #
  # Like a Promise, but evaluate and cache values on a per-thread basis
  #
  # e.g. will act just like a Promise if only called from one thread, but if
  # Thread A and Thread B both access a Promise created like so:
  #
  #   promise { Thread.current.object_id }
  #
  # Then they will see different values.  This does cache, and it does not
  # GC its cache when threads exit.  Thus if you expect to have a very
  # long-lived Promise accessed from many different threads that come and
  # go, don't use this.
  #

  def self.ThreadPromise(*args, &block)
    ZeevexDelayed::ThreadPromise.new(*args, &block)
  end

  def self.thread_promise(*args, &block)
    ZeevexDelayed::ThreadPromise.new(*args, &block)
  end

  class ThreadPromise < ZeevexProxy::BasicObject

    def initialize(&block)
      raise ::ArgumentError, "Must supply a block!" unless ::Kernel.block_given?
      super()
      @__promise_thread_map = {}
      @__promise_block = block
    end

    def method_missing(name, *args, &block)
      __force__.__send__(name, *args, &block)
    end

    def __force__
      unless @__promise_thread_map.has_key?(::Thread.current.object_id)
        @__promise_thread_map[::Thread.current.object_id] = @__promise_block.call
      end
      @__promise_thread_map[::Thread.current.object_id]
    end
  end
end

module Kernel
  def thread_promise(&block)
    ZeevexDelayed::ThreadPromise.new &block
  end
end
