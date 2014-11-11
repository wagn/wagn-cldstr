# -*- encoding : utf-8 -*-

class DeleteOldRelatedTabCards < Wagn::Migration
  def up
    [
      '*related',
      '*incoming',
      '*outgoing',
      '*community',
      '*plusses',
      'watcher instructions for related tab'
    ].each do |name|
      c = Card[name]
      c.codename = nil
      c.delete!
    end      
  end
end
