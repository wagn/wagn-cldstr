# -*- encoding : utf-8 -*-
require 'zip/zipfilesystem'

AIKI_ORIG = 'image'
AIKI_MARK = :watermark
AIKI_UPLOAD = 'item upload'

class AAHelper
  def self.aa_name cardname
    Card.exists?(cardname) ? "#{cardname}-#{Time.now.to_i}" : cardname
  end  
end

module Wagn
  Hook.add :after_save, "tags+*right" do |card|
    card.item_names.each do |name|
      if !Card.exists? name
        Card.create :name=>name
      end
    end
  end

  Hook.add :after_create, 'agree+*right' do |card|
    unless card.raw_content.to_i == 1
      msg = if msgcard = Card['eula error message']
        msgcard.content
      else
        "You must agree to the terms above to create an account."
      end
      card.errors.add :eula, msg
    end
  end

  Hook.add :after_save, "#{AIKI_UPLOAD}+*self" do |card|
    if file_card = Card["#{card.name}+file"]
      collection_card = Card["#{card.name}+collection"]
      tag_card = Card["#{card.name}+tags"]

      tmp_filename = '/tmp/aazipextractor'
  
      Zip::ZipFile.open file_card.attach.path do |zipfile|
        zipfile.each do |zf|
          m = zf.name.match /(.*)\.(\w+)$/
          cardname = AAHelper.aa_name( m[1] )
          tmpf = "#{tmp_filename}.#{m[2]}"
          zf.extract tmpf do true end
          Card.create! :name=>cardname, :type=>'Item'
          c = Card.new :name=>"#{cardname}+#{AIKI_ORIG}", :type=>'Image'
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

  Hook.add :after_save, "#{AIKI_ORIG}+*right" do |card|
    require 'RMagick'
    include Magick

    unless card.left.typecode == AIKI_MARK
    #~~~~~~~~ get "large" version of original and watermark
      img = Magick::Image.read( card.attach.path('large')            ).first
  
      #~~~~~ look up watermarks
      Card.search( :type=>'watermark' ).each do |watermark|
        markname = watermark.name

        next if toggle = Card["#{markname}+on"] and toggle.content != '1'
    
        mark  = Magick::Image.read( Card["#{markname}+#{AIKI_ORIG}"].attach.path ).first

        #~~~ get all the configuration options
        conf = {}
        [ :opacity, :gravity, :offset ].map do |c|
          if conf_card = Card["#{markname}+#{c}"]
            conf[c] = conf_card.content.strip
          end
        end
        conf[:opacity] = conf[:opacity] ? (conf[:opacity].to_f / 100.0) :  0.3
        conf[:gravity] = conf[:gravity] ? Card.const_get("#{conf[:gravity]}Gravity") :  NorthWestGravity
        conf[:offset]  = conf[:offset]  ? conf[:offset].to_i  : 5

        #~~~~~~ generate water mark 
        img = img.dissolve mark, conf[:opacity], 1, conf[:gravity], conf[:offset], conf[:offset]
      end

      #~~~~~~ save watermark to tmp file
      tmp_filename = "/tmp/watermark-#{card.current_revision_id}.jpg"

      quality_card = Card['*watermark+quality']
      img_quality = quality_card ? quality_card.content.strip.to_i : 100
  
      img.write( tmp_filename ) { self.quality = img_quality }

      #~~~~~~ create new card for watermarked version
      wcard = Card.fetch_or_new "#{card.cardname.trunk_name}+#{AIKI_MARK}", :type=>'Image'
      wcard = wcard.refresh
      wcard.attach = File.new( tmp_filename )
      wcard.save!
    end
  end


  module Set::AikidoArt
    include Sets
    
    format :html
  
    define_view :denial, :right=>AIKI_ORIG do |args|
      view = args[:denied_view] || :titled
    
      itemname = card.cardname.trunk_name
      @card = Card["#{itemname}+#{AIKI_MARK}"]
      _render view, args
    end
  
    define_view :core, :right=>AIKI_MARK do |args|
      if !Account.logged_in?
        args[:size] = :medium if [:large, :full, :original].member?( args[:size] )
      end
      _final_image_type_core args
    end  
  
    define_view :thumbnail, :type=>'item' do |args|
      wrap :thumbnail, args do
        text = subrenderer( Card["#{card.name}+image"] ).render_core :size=>:medium
        build_link card.name, text
      end
    end
  
    define_view :taglink do |args|
      build_link "#{card.name}+*tagged", card.name
    end
  
  end
end
