module Permissions
  class Base
    attr_reader :ability

    def initialize(ability)
      @ability = ability
    end

    def activate!
        raise NotImplementedError
    end

    delegate :can, :cannot, :user, to: :ability
  end
end
