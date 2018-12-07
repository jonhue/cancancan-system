# frozen_string_literal: true

# rubocop:disable Metrics/ModuleLength
module CanCanCan
  module System
    module Ability
      extend ActiveSupport::Concern

      def method_missing(method, *args)
        if method.to_s[/(.+)_abilities/]
          membership_abilities($1, *args)
        else
          super
        end
      end

      def respond_to_missing?(method, include_private = false)
        super || method.to_s[/(.+)_abilities/]
      end

      private

      def modify(aliases)
        alias_action(*aliases, to: :modify)
      end

      # rubocop:disable Metrics/MethodLength
      def abilities(klass, user, column: 'user', polymorphic: false,
                    public_abilities: true)
        public_abilities(klass) if public_abilities
        return unless user

        if polymorphic
          can(:manage, klass,
              "#{get_column(column)}": user.id,
              "#{get_column(column, 'type')}": user.class.name)
        else
          can(:manage, klass,
              "#{get_column(column)}": user.id)
        end
        yield if block_given?
      end
      # rubocop:enable Metrics/MethodLength

      # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity,
      # rubocop:disable Metrics/MethodLength, Metrics/ParameterLists,
      # rubocop:disable Metrics/PerceivedComplexity
      def membership_abilities(class_name, klass, user, scope: :membership,
                               column: nil, polymorphic: false,
                               acts_as_belongable: false)
        user.belongable_belongings.where(scope: scope).each do |belonging|
          next unless belonging.belonger_type == class_name.camelize

          ability = ability(belonging)
          if acts_as_belongable
            can(ability, klass,
                "#{column || class_name.pluralize}":
                  { id: belonging.belonger_id })
          elsif polymorphic
            can(ability, klass,
                "#{get_column(column || class_name)}": belonging.belonger_id,
                "#{get_column(column || class_name, 'type')}":
                  belonging.belonger_type)
          else
            can(ability, klass,
                "#{get_column(column || class_name)}": belonging.belonger_id)
          end
        end
        user.send(class_name.pluralize).each do |object|
          if acts_as_belongable
            can(:manage, klass,
                "#{column || class_name.pluralize}": { id: object.id })
          elsif polymorphic
            can(:manage, klass,
                "#{get_column(column || class_name)}": object.id,
                "#{get_column(column || class_name, 'type')}":
                  object.class.name)
          else
            can(:manage, klass,
                "#{get_column(column || class_name)}": object.id)
          end
        end
      end
      # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity,
      # rubocop:enable Metrics/MethodLength, Metrics/ParameterLists,
      # rubocop:enable Metrics/PerceivedComplexity

      def belongable_abilities(klass, user, scope: nil)
        if scope.nil?
          user.belongable_belongings.each do |belonging|
            belongable_belonging(klass, belonging)
          end
        else
          user.belongable_belongings
              .where(scope: scope).each do |belonging|
            belongable_belonging(klass, belonging)
          end
        end
      end

      def belongable_belonging(klass, belonging)
        return unless belonging.belonger_type == klass.name

        ability = ability(belonging)
        can(ability, klass, id: belonging.belonger_id) if ability
      end

      def belonger_abilities(klass, user, scope: nil)
        if scope.nil?
          user.belonger_belongings.each do |belonging|
            belonger_belonging(klass, belonging)
          end
        else
          user.belonger_belongings
              .where(scope: scope).each do |belonging|
            belonger_belonging(klass, belonging)
          end
        end
      end

      def belonger_belonging(klass, belonging)
        return unless belonging.belongable_type == klass.name

        ability = ability(belonging)
        can(ability, klass, id: belonging.belongable_id) if ability
      end

      def public_abilities(klass)
        can(:manage, klass, ability: 'admin', visibility: 'public')
        can(:modify, klass, ability: 'user', visibility: 'public')
        can(:read, klass, ability: 'guest', visibility: 'public')
      end

      def ability(object)
        case object.ability
        when 'admin'
          :manage
        when 'user'
          :modify
        when 'guest'
          :read
        else
          object.ability&.to_sym
        end
      end

      def get_column(column, name = 'id')
        return name if column.nil? || column == ''

        "#{column}_#{name}"
      end
    end
  end
end
# rubocop:enable Metrics/ModuleLength
