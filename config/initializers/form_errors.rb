# Add error messages inline after form fields

ActionView::Base.field_error_proc = proc do |html_tag, instance|
  html = ""

  form_fields = %w[input select textarea trix-editor]

  # Elements that can't have a border
  ignored_input_types = %w[checkbox hidden]

  Nokogiri::HTML::DocumentFragment.parse(html_tag).children.each do |e|
    html += if form_fields.include?(e.node_name) && ignored_input_types.exclude?(e.get_attribute("type"))
      e.add_class("error")
      %(#{e}<p class="form-hint error">&nbsp;#{instance.object.class.human_attribute_name(instance.send(:sanitized_method_name))} #{instance.error_message.uniq.to_sentence}</p>)
    else
      e.to_s
    end
  end

  html.html_safe
end
