class ApplicationDecorator < Draper::Decorator
  def attributes
    model.attributes
  end
  def pretty_show(table_class: "display table table-condensed table-responsive", title: '')
    h.render partial: 'general_show', locals: {object: self.attributes, title: title,  table_class: table_class}
  end
end