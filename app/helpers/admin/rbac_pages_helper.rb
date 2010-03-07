module Admin::RbacPagesHelper
  
  def current_user_can_see_element(page)
        
    return true if current_user.send("admin?")
    
    begin
      while page.role.nil?
        page = page.parent
      end
    
      if page.role.role_name == "Admin"
        return false
      elsif page.role.role_name == "Designer"
        if current_user.send("designer?")
          return true
        end
      else
        return true
      end
    rescue
      return true
    end
    
  end
  
  def node_title
    %{<span class="title">#{ h(@current_node.breadcrumb) }</span>}
  end 
  
end