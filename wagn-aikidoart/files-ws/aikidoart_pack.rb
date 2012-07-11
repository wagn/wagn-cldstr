AIKI_ORIG = 'image'
AIKI_MARK = 'watermark'

Wagn::Hook.add :after_save, "#{AIKI_ORIG}+*right" do |card|
  require 'RMagick'
  include Magick

  #~~~~~~~~ get "large" version of original and watermark
  large = Magick::Image.read( card.attach.path('large')            ).first
  mark  = Magick::Image.read( Card["*watermark+#{AIKI_ORIG}"].attach.path ).first

  #~~~ get all the configuration options
  conf = {}
  [ :opacity, :gravity, :quality ].map do |c|
    if conf_card = Card["*watermark+#{c}"]
      conf[c] = conf_card.content.strip
    end
  end
  conf[:opacity] = conf[:opacity] ? (conf[:opacity].to_f / 100.0) :  0.3
  conf[:gravity] = conf[:gravity] ? Card.const_get("#{conf[:gravity]}Gravity") :  NorthWestGravity
  conf[:quality] = conf[:quality] ? conf[:quality].to_i : 100

  #~~~~~~ generate water mark and save to tmp file
  marked = large.dissolve mark, conf[:opacity], 1, conf[:gravity]
  tmp_filename = "/tmp/watermark-#{card.current_revision_id}.jpg"
  marked.write( tmp_filename ) { self.quality = conf[:quality] }

  #~~~~~~ create new card for watermarked version
  wcard = Card.fetch_or_new "#{card.cardname.trunk_name}+#{AIKI_MARK}", :type=>'Image'
  wcard = wcard.refresh if wcard.frozen?
  wcard.attach = File.new( tmp_filename )
  wcard.save!
end


class Wagn::Renderer
  define_view :core, :right=>'approved_image' do |args|
    itemname = card.cardname.trunk_name
    orig = Card["#{itemname}+#{AIKI_ORIG}"]
    if orig = Card["#{itemname}+#{AIKI_ORIG}"] and orig.ok?(:read)
      @card = orig
    elsif mark = Card["#{itemname}+#{AIKI_MARK}"]
      @card = mark
    else
      return "Sorry, image is currently restricted"
    end
    render_core args
  end
end