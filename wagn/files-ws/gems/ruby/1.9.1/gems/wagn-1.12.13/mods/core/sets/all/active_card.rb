# -*- encoding : utf-8 -*-

def card_attributes
  if Card::Set.traits
    set_modules.each do |mod|
      if mod_traits = Card::Set.traits[mod]
        return mod_traits
      end
    end
  end
  nil
end

def trait_var? var_name
  !instance_variable_get( var_name ).nil?
end

def trait_var var_name, &block
  instance_variable_get( var_name ) ||
    instance_variable_set( var_name, block_given? ? yield : raise("no block?") )
end
