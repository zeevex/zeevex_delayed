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

  def self.ThreadLocalPromise(*args, &block)
    ZeevexDelayed::ThreadLocalPromise.new(*args, &block)
  end

  def self.thread_local_promise(*args, &block)
    ZeevexDelayed::ThreadLocalPromise.new(*args, &block)
  end

  class ThreadLocalPromise < ::ZeevexProxy::BasicObject

    NIL_SENTINEL = ::Object.new
    @serial = 0

    def self.nextid
      @serial += 1
    end

    def initialize(&block)
      raise ::ArgumentError, "Must supply a block!" unless ::Kernel.block_given?
      super()
      @__tlkey = "zx:tlp:#{::ZeevexDelayed::ThreadLocalPromise.nextid}"
      @__promise_block = block
    end

    def method_missing(name, *args, &block)
      __force__.__send__(name, *args, &block)
    end

    def __force__
      unless ::Thread.current.key?(@__tlkey)
        val = @__promise_block.call
        val = NIL_SENTINEL if val.nil?
        ::Thread.current[@__tlkey] = val
      end
      res = ::Thread.current[@__tlkey]
      res == NIL_SENTINEL ? nil : res
    end
  end
end

module Kernel
  def thread_local_promise(&block)
    ZeevexDelayed::ThreadLocalPromise.new &block
  end
end
