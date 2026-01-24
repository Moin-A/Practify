require 'rails_helper'

RSpec.describe Permissions::ClientPermissionSets, type: :model do
  let(:user) { create(:user) }
  let(:client_role) { create(:role, name: "Client") }
  let(:ability) { Ability.new(user) }
  let(:slot) { create(:slot) }

  before do
    # Assign Client role to user
    create(:role_user, user: user, role: client_role)
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
    let(:client_permission_set) { described_class.new(ability) }

    it 'responds to activate!' do
      expect(client_permission_set).to respond_to(:activate!)
    end

    it 'executes without raising an error' do
      expect { client_permission_set.activate! }.not_to raise_error
    end
  end

  describe 'slot permissions' do
    describe 'read permission' do
      it 'allows reading slots' do
        expect(ability.can?(:read, :slot)).to be true
      end

      it 'does not raise error when authorizing slot read' do
        expect { ability.authorize!(:read, :slot) }.not_to raise_error
      end
    end

    describe 'create permission' do
      it 'does not allow creating slots' do
        expect(ability.can?(:create, :slot)).to be false
      end

      it 'raises CanCan::AccessDenied when authorizing slot create' do
        expect { ability.authorize!(:create, :slot) }.to raise_error(CanCan::AccessDenied)
      end
    end

    describe 'destroy permission' do
      it 'does not allow destroying slots' do
        expect(ability.can?(:destroy, :slot)).to be false
      end

      it 'raises CanCan::AccessDenied when authorizing slot destroy' do
        expect { ability.authorize!(:destroy, :slot) }.to raise_error(CanCan::AccessDenied)
      end
    end

    describe 'update permission' do
      it 'does not allow updating slots' do
        expect(ability.can?(:update, :slot)).to be false
      end

      it 'raises CanCan::AccessDenied when authorizing slot update' do
        expect { ability.authorize!(:update, :slot) }.to raise_error(CanCan::AccessDenied)
      end
    end
  end
end
