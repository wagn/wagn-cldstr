
Wagn::Hook.add :after_save, 'original+*right' do |card|
  require 'RMagick'
  include Magick
  
  path = card.attach.path('large')
  exists = File.exists? path
  
  Rails.logger.info "~~~~\n\noriginal+*right called: path = #{path}, exists = #{exists} \n\n"
  mark = Magick::Image.read( Card['*watermark+image'].attach.path ).first
  large = Magick::Image.read( card.attach.path('large') ).first
  
  conf = {}
  [ :opacity, :gravity, :quality ].map do |c|
    if conf_card = Card["*watermark+#{c}"]
      conf[c] = conf_card.content.strip
    end
  end

  conf[:opacity] = conf[:opacity] ? (conf[:opacity].to_f / 100.0) :  0.3
  conf[:gravity] = conf[:gravity] ? Card.const_get("#{conf[:gravity]}Gravity") :  NorthWestGravity
  conf[:quality] = conf[:quality] ? conf[:quality].to_i : 100
  
  
  marked = large.dissolve mark, conf[:opacity], 1, conf[:gravity]
  tmp_filename = "/tmp/watermark-#{card.current_revision_id}.jpg"
  marked.write( tmp_filename ) { self.quality = conf[:quality] }
  tmp_file = File.new tmp_filename
  wcard = Card.fetch_or_new "#{card.cardname.trunk_name}+watermark", :type=>'Image'
  wcard = wcard.refresh if wcard.frozen?
  wcard.attach = tmp_file
  wcard.save
#  Card.create :type=>'Image', :name=>, :attach=>f
end