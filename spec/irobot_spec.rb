require 'spec_helper'

describe Irobot do
  context 'class methods' do
    it 'will provide certain methods' do
      Irobot.should respond_to(:allowed?)
      Irobot.should respond_to(:config)
      Irobot.should respond_to(:configure)
    end
  end

  context 'configuration' do
    it 'will provide defaults' do
      c = Irobot.config
      expect(c.timeout).to be Irobot::DEFAULT_TIMEOUT_IN_SECONDS
      expect(c.cache_namespace).to be Irobot::DEFAULT_CACHE_NAMESPACE
    end
  end

  context 'custom configuration' do
    let(:timeout) { 123 }
    let(:namespace) { :foobar }

    tmp = {}
    before(:all) do
      Irobot.configure do |c|
        tmp = c
        c.timeout = timeout
        c.cache_namespace = namespace
      end
    end

    after(:all) do
      Irobot.configure do |c|
        c = tmp
      end
    end

    it 'will accept arguments' do
      c = Irobot.config
      expect(c.timeout).to be timeout
      expect(c.cache_namespace).to be namespace
    end
  end
end
