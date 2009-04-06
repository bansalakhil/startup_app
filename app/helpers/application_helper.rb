# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def selected_class(path) 
    selected = ''
    if path.is_a? Array
      path.each do |p|
        if p.is_a? String
          selected = (current_page?(eval(p)) )?  'selected' : ''
        elsif p.is_a? Hash
          selected = (current_page?(p) )?  'selected' : ''
        end    
        return selected unless selected.blank?
      end
    else
      if path.is_a? String
        return (current_page?(eval(path)) )? 'selected' : ''
      elsif path.is_a? Hash
        return (current_page?(path) )? 'selected' : ''
      end 
    end
  end 
end
