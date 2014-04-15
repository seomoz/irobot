module Irobot
  class NullObject
    def method_missing(*args, &block)
      nil
    end

    def present?
      false
    end

    def nil?
      true
    end

    def to_ary
      []
    end
  end

  def Maybe(value)
    case value
    when nil then NullObject.new
    else value
    end
  end
end