# -*- coding: utf-8 -*-

$: << File.expand_path(File.dirname(__FILE__) + '../lib')

require 'rspec'
require 'zeevex_delayed'

puts "loading spec helper..."

# Be sure to include AuthenticatedTestHelper in spec/spec_helper.rb instead.
# Then, you can remove it from this and the functional test.

shared_examples_for "results caching" do
  it "should only call the block once" do
    @val = promise_class.new { canary.life }
    @val.__force__
    @val.__force__
  end
end


shared_examples_for "basic promise" do

  let :canary do
    mock("canary").tap do |mock|
      mock.stub(:doit).and_return("hello")
    end
  end

  let :test_promise do
    promise_class.new { canary.doit }
  end

  subject { test_promise }

  context "#initialize" do
    it "should not invoke the block during initialization" do
      canary = mock("canary")
      canary.should_receive(:oops).never

      @val = promise_class.new { canary.oops }
    end
  end

  it "should require a block" do
    expect { promise_class.new }.
        to raise_exception(ArgumentError)
  end

  it "should return the value of the block on to_s" do
    promise_class.new { "a" + "b" }.should == "ab"
  end

  it "should call the block only when needed" do
    foo = 1
    @val = promise_class.new { foo }
    foo = 2
    @val.should == 2
  end

  context "when forcing computation" do
    it "should respond to __force__" do
      # check here because respond_to? invoked on a promise would delegate
      promise_class.instance_methods.map(&:to_s).should include("__force__")
    end

    it "should be computed when Kernel#force_promise is called" do
      canary.should_receive(:doit).and_return('abcde')
      force_promise subject
    end
  end

  it "should return the block's value from __force__" do
    subject.__force__.should == "hello"
  end


  context "for blocks that return false" do
    let :canary do
      canary = mock("canary")
      canary.should_receive(:life).once.and_return(false)
      canary
    end
    it_should_behave_like "results caching"
  end

  context "for blocks that return nil" do
    let :canary do
      canary = mock("canary")
      canary.should_receive(:life).once.and_return(nil)
      canary
    end
    it_should_behave_like "results caching"
  end
end
