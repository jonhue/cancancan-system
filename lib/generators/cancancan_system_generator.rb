# frozen_string_literal: true

require 'rails/generators'
require 'rails/generators/migration'

class CancancanSystemGenerator < Rails::Generators::Base
  include Rails::Generators::Migration

  source_root File.join File.dirname(__FILE__), 'templates'
  desc 'Install CanCanCan System'

  def self.next_migration_number(dirname)
    if ActiveRecord::Base.timestamped_migrations
      Time.now.utc.strftime('%Y%m%d%H%M%S')
    else
      format('%.3d', current_migration_number(dirname) + 1)
    end
  end

  def create_migration_file
    migration_template 'migration.rb.erb',
                       'db/migrate/cancancan_system_migration.rb',
                       migration_version: migration_version
  end

  def show_readme
    readme 'README.md'
  end

  private

  def migration_version
    return unless Rails.version >= '5.0.0'

    "[#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}]"
  end
end
