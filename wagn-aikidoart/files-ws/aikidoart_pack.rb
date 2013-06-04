# -*- encoding : utf-8 -*-
require 'zip/zipfilesystem'
require 'RMagick'


class AAHelper  #fixme - want better patterns for adding custom classes
  def self.aa_name cardname, append_card
    cardname = Card.exists?(cardname) ? "#{cardname}-#{Time.now.to_i}" : cardname
    cardname = "#{cardname}+#{append_card.content}" if append_card and append_card.content.present?
    cardname
  end  
end

class Card #FIXME - just the right set (though test live; this broke before.)
  include Magick
end

module Wagn
  module Set
  
    #~~~~~~~~*all~~~~~~~~~~
  
    module All::AikidoArchives
      extend Sets
    
      format :html
  
      define_view :denial, :right=>:image do |args|
        view = args[:denied_view] || :titled
    
        itemname = card.cardname.trunk_name
        @card = Card["#{itemname}+watermark"]
        _render view, args
      end
  
      define_view :core, :right=>:watermark do |args|
        if !Account.logged_in?
          args[:size] = :medium if [:large, :full, :original].member?( args[:size] )
        end
        _final_image_type_core args
      end  
  
      define_view :thumbnail, :type=>'item' do |args|
        wrap :thumbnail, args do
          text = subrenderer( Card["#{card.name}+image"] ).render_core :size=>:medium
          card_link card.name, text, true
        end
      end
  
      define_view :taglink do |args|
        card_link "#{card.name}+*tagged", card.name, true
      end
    end
  
    #~~~~~~~~*right~~~~~~~~~~
  
    module Right
      module Tag #need codename
        extend Sets
        event :create_missing_tags, :after=>:store, :on=>:save do
          item_names.each do |name|
            if !Card.exists? name
              Card.create :name=>name
            end
          end
        end
      end
     
      module Agree #need codename
        extend Sets
        event :require_eula, :after=>:create do
          unless raw_content.to_i == 1
            msg = if msgcard = Card['eula error message']
              msgcard.content
            else
              "You must agree to the terms above to create an account."
            end
            errors.add :eula, msg
          end
        end
      end
    
      module Image
        extend Sets
        event :create_watermark, :after=>:store do
          warn "create watermark called for #{name}.  id = #{id}, revision = #{current_revision_id}"
    
          l = left
          unless l && l.typecode == :watermark
          #~~~~~~~~ get "large" version of original and watermark
            img = Magick::Image.read( self.attach.path 'large' ).first

            #~~~~~ look up watermarks
            Card.search( :type=>'watermark' ).each do |watermark|
              markname = watermark.name

              next if toggle = Card["#{markname}+on"] and toggle.content != '1'

              begin
                mark  = Magick::Image.read( Card["#{markname}+image"].attach.path ).first
              rescue
                raise "no watermark image!"
              end

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
            tmp_filename = "/tmp/watermark-#{current_revision_id}.jpg"

            quality_card = Card['*watermark+quality']
            img_quality = quality_card ? quality_card.content.strip.to_i : 100

            img.write( tmp_filename ) { self.quality = img_quality }

            #~~~~~~ create new card for watermarked version
            wcard = Card.fetch "#{cardname.trunk_name}+watermark", :new=>{ :type=>'Image' }
            wcard = wcard.refresh
            wcard.attach = File.new( tmp_filename )
            wcard.save!
          end
        end
      end
    end
  
    #~~~~~~~~*self~~~~~~~~~~
  
    module Self::ItemUpload #needs codename
      extend Sets
    
      event :extract_files, :after=>:store do

        if file_card = Card["#{name}+file"]
          collection_card = Card["#{name}+collection"]
          tag_card = Card["#{name}+tags"]
          append_card = Card["#{name}+append"]

          tmp_filename = '/tmp/aazipextractor'

          Zip::ZipFile.open file_card.attach.path do |zipfile|
            zipfile.each do |zf|
              m = zf.name.match /(.*)\.(\w+)$/
              cardname = AAHelper.aa_name m[1], append_card
              tmpf = "#{tmp_filename}.#{m[2]}"
              zf.extract tmpf do true end
              Card.create! :name=>cardname, :type=>'Item'
              c = Card.new :name=>"#{cardname}+image", :type=>'Image'
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
    end
  end
end