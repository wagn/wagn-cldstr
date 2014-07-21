# -*- encoding : utf-8 -*-
class Require18Migrations < ActiveRecord::Migration
  def self.up
    fail %{
Your database is not ready to be migrated to #{Wagn::Version.release}.
Please first install version 1.8.0 and run `rake db:migrate`.

Sorry about this! We're working to minimize these hassles in the future.
}
  end

  def self.down
    fail "Older migrations have been removed because of incompatibility."
  end
end
