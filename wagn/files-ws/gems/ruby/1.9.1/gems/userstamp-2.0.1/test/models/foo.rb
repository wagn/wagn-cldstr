class Foo < ActiveRecord::Base
  stampable :deleter_attribute => :deleter_id
end