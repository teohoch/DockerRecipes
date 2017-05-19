class ClientPresenceValidator < ActiveModel::EachValidator
  def validate_each(record, attr_name, value)
    true
  end
end