require 'spec_helper'
require 'cache_helper'

describe Irobot::Request do
  before(:all) do
    Irobot.configure do |c|
      c.cache = RequestCacheTest.new
    end
  end

  after(:all) do
    Irobot.configure do |c|
      c.delete(:cache)
    end
  end

  context 'class methods' do
    it 'will provide an allowed? method' do
      Irobot.should respond_to(:allowed?)
    end
  end

  describe 'public api' do
    subject { Irobot::Request.new('http://moz.com', 'dotbot') }

    [:to_key, :response, :request!, :allowed?].each do |meth|
      it { should respond_to(meth) }
    end
  end

  context 'cache' do
    let(:namespace) { Irobot.config.cache_namespace.to_s }
    let(:url) { 'http://example.com' }
    let(:ua) { 'dotbot' }

    describe 'key' do
      subject { Irobot::Request.new(url, ua) }

      its(:to_key) { should include(namespace) }
      its(:to_key) { should include(url) }
      its(:to_key) { should include(ua) }
    end
  end

  describe 'valid request!', :vcr do
    use_vcr_cassette
    subject { Irobot::Request.new('http://moz.com', 'dotbot') }
    its(:request!) { should be_a Irobot::Response }
  end

  describe 'timeout request!', :vcr do
    use_vcr_cassette

    before do
      Timeout.should_receive(:timeout).and_raise(Timeout::Error)
    end

    subject { Irobot::Request.new('http://moz.com', 'dotbot') }

    it 'should handle Timeout::Error' do
      expect { subject.request! }.not_to raise_error
    end

    its(:request!) { should be_a Irobot::Response }
  end
end
