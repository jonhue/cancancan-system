module CanCanCan
    module System
        module Ability

            extend ActiveSupport::Concern

            def method_missing m, *args
                if m.to_s[/(.+)_abilities/]
                    membership_abilities $1, args
                else
                    super
                end
            end

            def respond_to? m, include_private = false
                super || m.to_s[/(.+)_abilities/]
            end

            private

            def modify aliases
                alias_action aliases, to: :modify
            end

            def abilities record_class, user, options = {}
                defaults = {
                    column: 'user',
                    polymorphic: false,
                    public_abilities: true
                }
                options = defaults.merge options

                public_abilities record_class if options[:public_abilities]
                if user
                    if options[:polymorphic]
                        can :manage, record_class, "#{options[:column]}_id": user.id, "#{options[:column]}_type": user.class.name
                    else
                        can :manage, record_class, "#{options[:column]}_id": user.id
                    end
                    yield
                end
            end

            def membership_abilities class_name, record_class, user, options = {}
                defaults = {
                    scope: :membership,
                    column: nil,
                    polymorphic: false,
                    acts_as_belongable: false
                }
                options = defaults.merge options

                user.belongable_belongings.where(scope: options[:scope].to_s).each do |belonging|
                    if belonging.belonger_type == class_name.camelize
                        ability = ability belonging
                        if options[:acts_as_belongable]
                            can ability, record_class, "#{column || class_name.pluralize}": { id: belonging.belonger_id }
                        else
                            if options[:polymorphic]
                                can ability, record_class, "#{column || class_name}_id": belonging.belonger_id, "#{column || class_name}_type": belonging.belonger_type
                            else
                                can ability, record_class, "#{column || class_name}_id": belonging.belonger_id
                            end
                        end
                    end
                end
                user.send("#{class_name.pluralize}").each do |object|
                    if options[:acts_as_belongable]
                        can :manage, record_class, "#{column || class_name.pluralize}": { id: object.id }
                    else
                        if options[:polymorphic]
                            can :manage, record_class, "#{column || class_name}_id": object.id, "#{column || class_name}_type": object.class.name
                        else
                            can :manage, record_class, "#{column || class_name}_id": object.id
                        end
                    end
                end
            end

            def belongable_abilities record_class, user, options = {}
                defaults = {
                    scope: nil
                }
                options = defaults.merge options

                if scope.nil?
                    user.belongable_belongings.each do |belonging|
                        belongable_belonging belonging
                    end
                else
                    user.belongable_belongings.where(scope: scope.to_s).each do |belonging|
                        belongable_belonging belonging
                    end
                end
            end
            def belongable_belonging belonging
                if belonging.belonger_type == record_class.name
                    ability = ability belonging
                    can ability, record_class, id: belonging.belonger_id if ability
                end
            end

            def belonger_abilities record_class, user, options = {}
                defaults = {
                    scope: nil
                }
                options = defaults.merge options

                if scope.nil?
                    user.belonger_belongings.each do |belonging|
                        belonger_belonging belonging
                    end
                else
                    user.belonger_belongings.where(scope: scope.to_s).each do |belonging|
                        belonger_belonging belonging
                    end
                end
            end
            def belonger_belonging belonging
                if belonging.belongable_type == record_class.name
                    ability = ability belonging
                    can ability, record_class, id: belonging.belongable_id if ability
                end
            end

            def public_abilities record_class
                can :manage, record_class, ability: 'admin', visibility: 'public'
                can :modify, record_class, ability: 'user', visibility: 'public'
                can :read, record_class, ability: 'guest', visibility: 'public'
            end

            def ability object
                case object.ability
                when 'admin'
                    :manage
                when 'user'
                    :modify
                when 'guest'
                    :read
                when nil
                    nil
                else
                    object.ability.to_sym
                end
            end

        end
    end
end
