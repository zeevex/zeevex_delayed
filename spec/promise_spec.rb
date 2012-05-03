# -*- coding: utf-8 -*-

require File.expand_path(File.dirname(__FILE__) + '/spec_helper.rb')

describe ZeevexDelayed::Promise do

  let :promise_class do
    ZeevexDelayed::Promise
  end

  context "as a basic promise" do
    it_should_behave_like "basic promise"
  end
  
  context "when called from different threads" do
    it "should call the block once for all threads" do
      canary = mock("canary")
      canary.should_receive(:life).once.and_return(42)

      @val = promise_class.new { canary.life }

      Thread.new { @val.to_i }.join
      Thread.new { @val.to_i }.join
    end
  end

end
