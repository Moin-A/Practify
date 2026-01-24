require 'rails_helper'

RSpec.describe Ability, type: :model do
  let(:user) { User.new }
  let(:role) { create(:role) }
  let(:role_user) { create(:role_user, user: user, role: role) }
  let(:role_configuration) { instance_double(RoleConfiguration) }

  before do
    allow(Practify.config).to receive(:roles).and_return(role_configuration)
  end

  describe 'initialization' do
    it 'calls activate_permissions on RoleConfiguration when initializing' do
      expect(role_configuration).to receive(:activate_permissions).with(an_instance_of(Ability), user)
      described_class.new(user)
    end

    it 'return cancan errot if user does not have the required permissions' do
      expect(role_configuration).to receive(:activate_permissions).with(an_instance_of(Ability), user)
      described_class.new(user)
    end
  end
end
