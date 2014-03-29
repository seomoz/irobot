require 'spec_helper'

describe Irobot::Request do
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
end
