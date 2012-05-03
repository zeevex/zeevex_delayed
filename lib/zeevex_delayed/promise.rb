require 'zeevex_proxy'

module ZeevexDelayed
  def self.Promise(*args, &block)
    ZeevexDelayed::Promise.new(*args, &block)
  end

  def self.promise(*args, &block)
    ZeevexDelayed::Promise.new(*args, &block)
  end
  
  class Promise < ZeevexProxy::Base

    def initialize(obj=nil, &block)
      super
      @__promise_block = block
      raise ArgumentError, "Must supply a block!" unless block
    end

    def method_missing(name, *args, &block)
      __force__.__send__(name, *args, &block)
    end

    def __force__
      unless @__promise_forced
        @obj = @__promise_block.call
        @__promise_forced = true
      end
      @obj
    end
  end
end

module Kernel
  def force_promise(promise)
    promise.__force__
  end

  def promise(&block)
    ZeevexDelayed::Promise.new &block
  end
end
