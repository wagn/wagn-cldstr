# -*- encoding : utf-8 -*-
require 'rails/generators/active_record'

class CardMigrationGenerator < ActiveRecord::Generators::Base
  source_root File.expand_path('../templates', __FILE__)
  
  class_option 'core', :type => :boolean, aliases: '-c', :default => false, :group => :runtime, 
    desc: "Create card migration for wagn core"

  def create_migration_file
    root = options['core'] ? Wagn::Migration.card_migration_paths.first : Wagn::Migration.deck_card_migration_paths.first
    set_local_assigns!
    migration_template @migration_template, File.join( root, "#{file_name}.rb")
  end
  
  protected
  
  # sets the default migration template that is being used for the generation of the migration
  # depending on the arguments which would be sent out in the command line, the migration template 
  # and the table name instance variables are setup.

  def set_local_assigns!
    @migration_template = "card_migration.erb"
    @migration_parent_class = options['core'] ? 'Wagn::CoreMigration' : 'Wagn::Migration'
    case file_name
    when /^(import)_(.*)(?:\.json)?/
      @migration_action = $1
      @json_filename    = "#{$2}.json"
    end
  end
end