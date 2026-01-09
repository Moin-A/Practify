class RoleConfiguration
  class Role
    attr_accessor :name, :permissionsSets
    def initialize(name)
      @name = name
      @permissionsSets = Practify::Core::ClassConstantizer::Set.new
    end
  end

  def initialize
    @role = Hash.new do |hash, name|
      hash[name] = Role.new(name)
    end        
  end

  def assign_permissions(name, permission_sets)      
    @role[name.to_sym].permissionsSets.concat permission_sets
  end


  def activate_permissions(ability)
    # roles = ['default'] | user.spree_roles.map(&:name)
    roles = [ "default", "customer" ]
    applicable_permissions = Set.new


    roles.each do |role_name|
      applicable_permissions |= @role[role_name.to_sym].permissionsSets
    end

    applicable_permissions.each do |permission_set_class|
      permission_set_class.constantize.new(ability).activate!
    end
  end
end
