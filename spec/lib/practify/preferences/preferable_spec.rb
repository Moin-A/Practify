require 'rails_helper'

RSpec.describe Practify::Preferences::Preferable do
  describe 'DSL functionality' do
    let(:test_class) do
      Class.new do
        include Practify::Preferences::Preferable
      end
    end

    it 'allows a class to use the preference DSL' do
      expect(test_class).to respond_to(:preference)
      expect(test_class).to respond_to(:defined_preferences)

      test_class.preference :setting1, :string, default: 'value1'
      test_class.preference :setting2, :integer, default: 42

      expect(test_class.defined_preferences).to include(:setting1, :setting2)
    end

    it 'accepts preferences with various options' do
      test_class.preference :string_setting, :string, default: 'test'
      test_class.preference :encrypted_setting, :string, encryption_key: 'secret'
      test_class.preference :combined_setting, :string, default: 'value', encryption_key: 'key'

      preferences = test_class.defined_preferences
      expect(preferences).to include(:string_setting, :encrypted_setting, :combined_setting)
    end

    it 'converts string preference names to symbols' do
      test_class.preference 'string_name', :string, default: 'value'
      expect(test_class.defined_preferences).to include(:string_name)
    end

    it 'allows multiple preferences to be defined' do
      test_class.preference :pref1, :string
      test_class.preference :pref2, :integer
      test_class.preference :pref3, :boolean

      preferences = test_class.defined_preferences
      expect(preferences.length).to eq(3)
      expect(preferences).to include(:pref1, :pref2, :pref3)
    end

    it 'does not share mutable default values between instances' do
      test_class.preference :tags, :array, default: []
      instance1 = test_class.new
      instance1.tags << "admin"
      instance2 = test_class.new
      expect(instance2.tags).to eq([])  # This would FAIL without Proc wrapping
      expect(instance2.tags).not_to equal(instance1.tags)  # Different object
    end
  end

  describe 'preference isolation between classes' do
    let(:first_class) do
      Class.new do
        include Practify::Preferences::Preferable
      end
    end

    let(:second_class) do
      Class.new do
        include Practify::Preferences::Preferable
      end
    end

    it 'keeps preferences separate for different classes' do
      first_class.preference :first_setting, :string, default: 'first_value'
      first_class.preference :first_only, :integer, default: 10

      second_class.preference :second_setting, :string, default: 'second_value'
      second_class.preference :second_only, :boolean, default: true

      # First class should only have its own preferences
      first_preferences = first_class.defined_preferences
      expect(first_preferences).to include(:first_setting, :first_only)
      expect(first_preferences).not_to include(:second_setting, :second_only)

      # Second class should only have its own preferences
      second_preferences = second_class.defined_preferences
      expect(second_preferences).to include(:second_setting, :second_only)
      expect(second_preferences).not_to include(:first_setting, :first_only)
    end

    it 'allows different classes to have preferences with the same name' do
      first_class.preference :shared_name, :string, default: 'first_value'
      second_class.preference :shared_name, :integer, default: 100

      # Both should have :shared_name but they are separate instances
      expect(first_class.defined_preferences).to include(:shared_name)
      expect(second_class.defined_preferences).to include(:shared_name)

      # Verify they work independently by adding a unique preference to each
      first_class.preference :first_unique, :string
      second_class.preference :second_unique, :string

      expect(first_class.defined_preferences).to include(:shared_name, :first_unique)
      expect(first_class.defined_preferences).not_to include(:second_unique)

      expect(second_class.defined_preferences).to include(:shared_name, :second_unique)
      expect(second_class.defined_preferences).not_to include(:first_unique)
    end

    it 'does not leak preferences when adding to one class' do
      first_class.preference :before, :string, default: 'value'

      initial_first_count = first_class.defined_preferences.length
      initial_second_count = second_class.defined_preferences.length

      # Add preference to second class
      second_class.preference :after, :string, default: 'value'

      # First class should not be affected
      expect(first_class.defined_preferences.length).to eq(initial_first_count)
      expect(first_class.defined_preferences).not_to include(:after)

      # Second class should have the new preference
      expect(second_class.defined_preferences.length).to eq(initial_second_count + 1)
      expect(second_class.defined_preferences).to include(:after)
    end
  end
end
