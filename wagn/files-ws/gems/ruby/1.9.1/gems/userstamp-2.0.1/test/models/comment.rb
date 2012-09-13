# this class is only meant for compatability mode testing
class Comment < ActiveRecord::Base
  stampable   :stamper_class_name => :person
  belongs_to  :post
end