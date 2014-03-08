# -*- encoding : utf-8 -*-

class Card::Codename

  @@codehash=nil

  class << self
    # returns codename for id and vice versa.  not in love with this api --efm
    def [] key
      if !key.nil?
        key = key.to_sym unless Integer===key
        codehash[key]
      end
    end

    def codehash
      @@codehash || load_hash
    end

    def reset_cache
      @@codehash = nil
    end

    #only used in migration
    def bootdata hash
      @@codehash = hash
    end


    private

    def load_hash
      @@codehash = {}
      sql = 'select id, codename from cards where codename is not NULL'
      ActiveRecord::Base.connection.select_all(sql).each do |row|
        #FIXME: remove duplicate checks, put them in other tools
        code, cid = row['codename'].to_sym, row['id'].to_i
        if @@codehash.has_key?(code) or @@codehash.has_key?(cid)
          warn "dup code ID:#{cid} (#{@@codehash[code]}), CD:#{code} (#{@@codehash[cid]})"
        end
        @@codehash[code] = cid; @@codehash[cid] = code
      end

      @@codehash
    end
  end
end
