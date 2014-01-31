# -*- encoding : utf-8 -*-
require_dependency 'active_support/builder' unless defined?(Builder)

format :kml do

  view :show do |args|
    render( args[:view] || :search)
  end

  # FIXME: integrate this with common XML features when it is added
  view :search do |args|
    xml = Builder::XmlMarkup.new
    xml.instruct! :xml, :version => "1.0"

    xml.kml do
      xml.Document do

        cardnames = Account.as_bot do
          # Note: we use wagn_bot to find all the applicable cards, but not for the geocode or description cards
          # This is a workaround so that folks can have maps so long as their geocode cards are publicly viewable.
          # needs deeper redesign
          if card.type_id==Card::SearchTypeID
            card.item_cards( search_params.merge(:return=>:name, :limit=>1000) )
          else
            [card.name]
          end
        end

        cardnames.each do |cardname|
          geocard = Card["#{cardname}+*geocode"]
          if geocard && geocard.ok?(:read)
            xml.Placemark do
              xml.name cardname
              if desc_card = Card.fetch("#{cardname}+*geodescription") and desc_card.ok? :read
                xml.description Card::Format.new(desc_card).render_core(args)
              end
              xml.Point do
                # apparently the google API likes them in the opposite order for static maps.
                # since we don't have code in the static maps address, we store them that way.
                xml.coordinates geocard.content.split(',').reverse.join(',')
              end
            end
          end
        end
      end
    end
  end
end
