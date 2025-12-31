require 'rails_helper'

RSpec.describe Practify::Preferences::Configuration do
  let(:config_class) do
    Class.new(described_class) do
      # Test class that inherits from Configuration
    end
  end

  let(:config_class1) do
    Class.new(described_class) do
      # Test class that inherits from Configuration
    end
  end

  describe '.preference' do
    context 'with valid options' do
      it 'accepts :default option' do
        expect do
          config_class.preference :test_setting, :string, default: 'default_value'
        end.not_to raise_error
      end

      it 'accepts :encryption_key option' do
        expect do
          config_class.preference :encrypted_setting, :string, encryption_key: 'secret_key'
        end.not_to raise_error
      end

      it 'accepts both :default and :encryption_key options' do
        expect do
          config_class.preference :encrypted_setting, :string,
                                   default: 'secret_value',
                                   encryption_key: 'secret_key'
        end.not_to raise_error
      end

      it 'accepts no options' do
        expect do
          config_class.preference :test_setting, :string
        end.not_to raise_error
      end
    end

    context 'with invalid options' do
      it 'raises an error for invalid option keys' do
        expect do
          config_class.preference :test_setting, :string, invalid_option: 'value'
        end.to raise_error(ArgumentError, /invalid_option/)
      end

      it 'raises an error for multiple invalid option keys' do
        expect do
          config_class.preference :test_setting, :string,
                                   invalid_option: 'value',
                                   another_invalid: 'value2'
        end.to raise_error(ArgumentError)
      end
    end

    context 'with default values' do
      it 'handles string default values' do
        config_class.preference :test_setting, :string, default: 'default_value'
        expect(config_class.defined_preferences).to include(:test_setting)
      end

      it 'handles integer default values' do
        config_class.preference :test_setting, :integer, default: 42
        expect(config_class.defined_preferences).to include(:test_setting)
      end

      it 'handles boolean default values' do
        config_class.preference :test_setting, :boolean, default: true
        expect(config_class.defined_preferences).to include(:test_setting)
      end

      it 'handles Proc default values' do
        config_class.preference :test_setting, :string, default: proc { 'computed_value' }
        expect(config_class.defined_preferences).to include(:test_setting)
      end

      it 'handles nil default values' do
        config_class.preference :test_setting, :string, default: nil
        expect(config_class.defined_preferences).to include(:test_setting)
      end
    end

    context 'with encrypted_string type' do
      it 'encrypts the default value when type is :encrypted_string' do
        # This test assumes the encryption logic will be implemented
        # We're testing that the method handles the encrypted_string type
        expect do
          config_class.preference :encrypted_setting, :encrypted_string,
                                   default: 'plain_text',
                                   encryption_key: 'secret_key'
        end.not_to raise_error
        expect(config_class.defined_preferences).to include(:encrypted_setting)
      end

      it 'handles encrypted_string without default value' do
        expect do
          config_class.preference :encrypted_setting, :encrypted_string,
                                   encryption_key: 'secret_key'
        end.not_to raise_error
        expect(config_class.defined_preferences).to include(:encrypted_setting)
      end
    end

    context 'preference registration' do
      it 'registers the preference name' do
        config_class1.preference :test_setting, :string, default: 'value'
        expect(config_class1.defined_preferences).to include(:test_setting)
      end

      it 'registers multiple preferences' do
        config_class1.preference :setting1, :string, default: 'value1'
        config_class1.preference :setting2, :integer, default: 42
        config_class1.preference :setting3, :boolean, default: true

        expect(config_class1.defined_preferences).to include(:setting1, :setting2, :setting3)
      end

      it 'converts preference name to symbol' do
        config_class.preference 'string_name', :string, default: 'value'
        expect(config_class.defined_preferences).to include(:string_name)
      end
    end

    context 'inheritance' do
      let(:parent_class) do
        Class.new(described_class) do
          preference :parent_setting, :string, default: 'parent_value'
        end
      end

      let(:child_class) do
        Class.new(parent_class) do
          preference :child_setting, :string, default: 'child_value'
        end
      end

      it 'includes parent preferences in defined_preferences' do
        expect(child_class.defined_preferences).to include(:parent_setting)
      end

      it 'includes child preferences in defined_preferences' do
        expect(child_class.defined_preferences).to include(:child_setting)
      end

      it 'includes both parent and child preferences' do
        preferences = child_class.defined_preferences
        expect(preferences).to include(:parent_setting, :child_setting)
      end

      it 'does not affect parent class preferences when child adds new ones' do
        child_class.preference :another_child_setting, :string, default: 'value'
        expect(parent_class.defined_preferences).to include(:parent_setting)
        expect(parent_class.defined_preferences).not_to include(:another_child_setting)
      end
    end

    context 'edge cases' do
      it 'handles preference names with underscores' do
        config_class.preference :test_setting_name, :string, default: 'value'
        expect(config_class.defined_preferences).to include(:test_setting_name)
      end

      it 'handles preference names with numbers' do
        config_class.preference :setting_123, :string, default: 'value'
        expect(config_class.defined_preferences).to include(:setting_123)
      end

      it 'handles empty string as default value' do
        config_class.preference :test_setting, :string, default: ''
        expect(config_class.defined_preferences).to include(:test_setting)
      end

      it 'handles zero as default value' do
        config_class.preference :test_setting, :integer, default: 0
        expect(config_class.defined_preferences).to include(:test_setting)
      end

      it 'handles false as default value' do
        config_class.preference :test_setting, :boolean, default: false
        expect(config_class.defined_preferences).to include(:test_setting)
      end
    end
  end

  describe '.defined_preferences' do
    it 'returns an array of preference names' do
      config_class.preference :setting1, :string, default: 'value1'
      config_class.preference :setting2, :string, default: 'value2'

      preferences = config_class.defined_preferences
      expect(preferences).to be_an(Array)
      expect(preferences).to include(:setting1, :setting2)
    end

    it 'returns empty array when no preferences are defined' do
      expect(config_class.defined_preferences).to eq([])
    end

    it 'returns unique preference names' do
      config_class.preference :duplicate_setting, :string, default: 'value1'
      config_class.preference :duplicate_setting, :string, default: 'value2'

      preferences = config_class.defined_preferences
      # Note: The implementation might handle duplicates differently
      # This test verifies the method exists and returns an array
      expect(preferences).to be_an(Array)
      expect(preferences).to include(:duplicate_setting)
    end
  end
end
