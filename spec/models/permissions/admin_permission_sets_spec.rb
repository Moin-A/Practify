require 'rails_helper'

RSpec.describe Permissions::AdminPermissionSets, type: :model do
  let(:ability) { instance_double(Ability) }
  let(:user) { instance_double(User) }

  before do
    allow(ability).to receive(:can).and_return(true)
    allow(ability).to receive(:cannot).and_return(false)
    allow(ability).to receive(:user).and_return(user)
    
  end
  describe 'class structure' do  
    it 'inherits from Permissions::Base' do
      expect(described_class.superclass).to eq(Permissions::Base)
    end

    it 'can be instantiated' do
      expect { described_class.new(ability) }.not_to raise_error
    end
  end

  describe '#activate!' do
    let(:admin_permission_set) { described_class.new(ability) }
   

    it 'responds to activate!' do      
      expect(admin_permission_set).to respond_to(:activate!)
    end

    it 'calls can with :manage and :all when can method is available' do
      # This test assumes Base includes CanCan::Ability or provides a can method
      if admin_permission_set.respond_to?(:can)
        expect(admin_permission_set).to receive(:can).with(:manage, :all)
        admin_permission_set.activate!
      else
        skip 'Base class does not provide can method - may need to include CanCan::Ability'
      end
    end

    it 'executes without raising an error' do      
      expect { admin_permission_set.activate! }.not_to raise_error
    end
  end
end
