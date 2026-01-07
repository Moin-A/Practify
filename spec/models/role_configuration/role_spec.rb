require 'rails_helper'

RSpec.describe RoleConfiguration::Role, type: :model do
  describe '#permissions' do
    let(:role) { described_class.new('test_role') }

    it 'responds to permissionSet' do
      expect(role).to respond_to(:permissionsSets)
    end
  end
end
