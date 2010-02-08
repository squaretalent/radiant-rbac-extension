# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application_controller'

class RbacExtension < Radiant::Extension
  
  version "0.1"
  description "Restricts user access to pages, regions and tabs based on their role"
  url "http://github.com/squaretalent/radiant-rbac-extension"
  
  define_routes do |map|
    map.namespace :admin do |admin|
      admin.resources :roles
      admin.role_user '/roles/:role_id/users/:id', :controller => 'roles', :action => 'remove_user', :conditions => {:method => :delete}
      admin.role_user '/roles/:role_id/users/:id', :controller => 'roles', :action => 'add_user', :conditions => {:method => :post}
      admin.role_users '/roles/:role_id/users', :controller => 'roles', :action => 'users', :conditions => {:method => :get}
    end
  end

  def activate
    
    if Role.table_exists?
      
      extend_users
      extend_pages
      update_interface
      
    end
    
  end

  def update_interface
    
    tab :Settings do
      add_item :Roles, "/admin/roles", :after => :Users
    end
    
    admin.users.edit[:form].delete('edit_roles')
    
    Admin::SnippetsController.class_eval do
     only_allow_access_to :index, :new, :edit, :update, :create, :destroy,
       :when => [ :admin ],
       :denied_url => {:controller => 'welcome', :action => 'index'},
       :denied_message => "You can not access snippets."
    end
    
    Admin::LayoutsController.class_eval do
      only_allow_access_to :index, :new, :edit, :update, :create, :destroy,
        :when => [ :admin, :designer ],
        :denied_url => {:controller => 'welcome', :action => 'index'},
        :denied_message => "You can not access layouts."
    end

    Admin::RolesController.class_eval do
      only_allow_access_to :index, :show, :new, :create, :edit, :update, :remove_user, :add_user, :users, :destroy,
        :when => [ :admin ],
        :denied_url => { :controller => 'pages', :action => 'index' },
        :denied_message => "You can not access roles."
    end
    
  end
  
  def extend_users
    
    Admin::UsersController.class_eval do
      helper Admin::RbacUsersHelper
    end
    
    User.send :has_many, :designations, :dependent => :destroy
    User.send :has_many, :roles, :through => :designations
    User.send :include, UsersRolesExtensions

    UserActionObserver.instance.send :add_observer!, Role
    
  end
  
  def extend_pages
    
    Page.class_eval do
      belongs_to :role
    end
    
    Role.class_eval do
      if Page.column_names.include?('role_id')
        has_many :pages, :dependent => :nullify
      end
    end
    
    Admin::PagesController.class_eval do
      helper Admin::RbacPagesHelper
    end

    admin.page.index[:node].delete('title_column')
    admin.page.index[:node].delete('remove_column')
    admin.page.index[:node].delete('add_child_column')
    admin.page.index.add :node, 'title_column_subject_to_permissions', :before => 'status_column'
    admin.page.index.add :node, 'remove_column_subject_to_permissions', :after => 'status_column'
    admin.page.index.add :node, 'add_child_column_subject_to_permissions', :after => 'status_column'

    Admin::PagesController.send :include, PagesRolesExtensions
    admin.pages.index.add :node, "page_role_td", :before => "status_column"
    admin.pages.index.add :sitemap_head, "page_role_th", :before => "status_column_header"
    admin.pages.edit.add :parts_bottom, "page_role", :after => "edit_timestamp"
    admin.pages.index[:node].delete('sitemap_head')
    
  end
  
end
