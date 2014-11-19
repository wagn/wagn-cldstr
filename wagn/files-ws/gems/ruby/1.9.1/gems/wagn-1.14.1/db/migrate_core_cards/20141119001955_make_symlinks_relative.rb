# -*- encoding : utf-8 -*-

class MakeSymlinksRelative < Wagn::Migration
  def up
    Wagn.paths['files'].each do |file_path| 
      files = Dir.glob(File.join file_path, '**', '*')
      symlinks = files.select {|f| File.symlink? f }
      symlinks.each do |symlink|
        base = File.basename( File.readlink(symlink) )
        File.delete symlink
        File.symlink base, symlink
      end
    end
  end
end
