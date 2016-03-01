# -*- encoding : utf-8 -*-

#require 'zip/zipfilesystem' - versioning broke this

event :extract_files, :finalize do

  if file_card = Card["#{name}+file"]
    collection_card = Card["#{name}+collection"]
    tag_card = Card["#{name}+tags"]
    append_card = Card["#{name}+append"]
    item_type_card = Card["#{name}+item type"]

    tmp_filename = '/tmp/aazipextractor'

    Zip::ZipFile.open file_card.attach.path do |zipfile|
      zipfile.each do |zf|
        m = zf.name.match /(.*)\.(\w+)$/
        cardname = AAHelper.aa_name m[1], append_card
        tmpf = "#{tmp_filename}.#{m[2]}"
        zf.extract tmpf do true end
        Card.create! :name=>cardname, :type=>'Item'
        item_type = item_type_card.item_names.first
        c = Card.new :name=>"#{cardname}+#{item_type.downcase}", :type=>item_type
        c.attach = File.new(tmpf)
        c.save!
        if collection_card
          Card.create! :name=>"#{cardname}+collection", :type=>'Pointer', :content=>collection_card.content
        end
        if tag_card
          Card.create! :name=>"#{cardname}+tags",       :type=>'Pointer', :content=>tag_card.content
        end

      end
    end
  end
end


class AAHelper
  def self.aa_name cardname, append_card
    cardname = Card.exists?(cardname) ? "#{cardname}-#{Time.now.to_i}" : cardname
    cardname = "#{cardname}+#{append_card.content}" if append_card and append_card.content.present?
    cardname
  end
end

