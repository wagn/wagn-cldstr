require 'rmagick'

include Magick 

format :html do
  view :denial do |args|
    view = args[:denied_view] || :titled

    itemname = card.cardname.trunk_name
    @card = Card["#{itemname}+#{ Card[:watermark].name }"]
    _render view, args
  end
end


event :create_watermark, :before=>:extend do
  #warn "create watermark called for #{name}.  id = #{id}, revision = #{current_revision_id}"

  l = left
  unless l && l.type_code == :watermark
  #~~~~~~~~ get "large" version of original and watermark
    begin
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
    rescue
      # FIXME - should not have this rescue.  failing because image file saving hasn't happened yet (I think)
      
    end
  end
  
end
