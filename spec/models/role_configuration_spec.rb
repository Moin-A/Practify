require 'rails_helper'

RSpec.describe RoleConfiguration, type: :model do
  let(:ability) { instance_double(Ability) }
  let(:user) { create(:user) }
  let(:role) { create(:role) }
  let(:role_user) { create(:role_user, user: user, role: role) }
  describe 'class structure' do
    it 'can be instantiated' do
      expect { described_class.new }.not_to raise_error
    end
  end

  describe '#activate' do
    let(:role_configuration) { described_class.new }

    it 'responds to activate_permissions' do
      expect(role_configuration).to respond_to(:activate_permissions)
    end

    it 'executes without raising an error' do
      expect { role_configuration.activate_permissions(ability, user) }.not_to raise_error
    end
  end
end
