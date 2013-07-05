
require File.expand_path(File.dirname(__FILE__) + '/spec_helper.rb')

require 'zeevex_delayed/thread_local_promise'

describe ZeevexDelayed::ThreadLocalPromise do

  let :promise_class do
    ZeevexDelayed::ThreadLocalPromise
  end

  context "as a basic promise" do
    it_should_behave_like "basic promise"
  end

  context "when called from different threads" do
    it "should call the block again for each new thread" do
      canary = mock("canary")
      canary.should_receive(:life).twice.and_return(42)

      @val = promise_class.new { canary.life }

      Thread.new { @val.to_i }.join
      Thread.new { @val.to_i }.join
    end

    it "should call the block only once for each thread" do
      canary = mock("canary")
      canary.should_receive(:life).twice.and_return(42)

      @val = promise_class.new { canary.life }

      Thread.new { @val.to_i; @val.to_i }.join
      Thread.new { @val.to_i; @val.to_i }.join
    end
  end
end
