module PagesRolesExtensions
  
  def self.included(base)
    base.class_eval {
      only_allow_access_to :new,
        :if => :user_is_in_page_role,
        :denied_url => { :controller => 'pages', :action => 'index' },
        :denied_message => "You aren't in an appropriate role for editing or adding children to that page."
      
      only_allow_access_to :edit,
        :if => :not_for_clients,
        :denied_url => { :controller => 'pages', :action => 'index' },
        :denied_message => "You aren't in an appropriate role to access that area."
        
      def user_is_in_page_role
        return true if current_user.admin?
  
        page = Page.find(params[:id] || params[:page_id] || params[:parent_id])
  
        until page.nil? do
          unless page.role.nil?
            return true if current_user.send("#{page.role.role_name.underscore}?")
          end
          page = page.parent
        end
  
        return false
      end
      
      def not_for_clients
        return true if current_user.admin?
        
        page = Page.find(params[:id] || params[:page_id] || params[:parent_id])
        
        until page.nil? do
          unless page.role.nil?
            if page.role.role_name == "Admin"
              return false
            elsif page.role.role_name == "Designer"
              return true if current_user.send("designer?")
            else
              return true
            end
          end
          page = page.parent
        end
        
        return false
      end

      before_filter :disallow_role_change
      def disallow_role_change
        if params[:page] && !current_user.admin?
          params[:page].delete('role_id')
        end
      end
    }
  end
  
end