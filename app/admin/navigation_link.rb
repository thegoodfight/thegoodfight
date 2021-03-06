ActiveAdmin.register NavigationLink do
  actions :all, except: [:show]
  config.filters = false
  menu label: "Navbar"

  form do |f|
    f.inputs "Link details" do
      f.input :title

      f.input :linkable_id,
        label: "Internal Location",
        as: :polymorphic_select,
        collection: f.object.linkables,
        option_label: :linkable_title,
        hint: "Use EITHER this OR External Location. Leave blank if you want this to be a parent link."

      f.input :location,
        label: "External Location",
        hint: "Use EITHER this OR Internal Location. Leave blank if you want this to be a parent link."

      f.input :linkable_type, as: :hidden

      f.input :parent_link, as: :select, collection: Hash[f.object.potential_parents.map {|nl| [nl.title, nl.id]}]
    end
    f.actions
  end

  controller do
    def active_admin_collection
      NavigationLink.ordered_by_position.page(params[:page]).per(100)
    end
  end

  index do
    column :title do |link|
      if link.root_link?
        link.title
      else
        link.parent_link.title + " > " + link.title
      end
    end
    column :parent_link
    column :url

    default_actions
    column :move_position do |link|
      up_link = if link.first?
        link_to icon(:arrow_up, color: "#eee !important"), "#", disabled: true
      else
        link_to icon(:arrow_up), up_admin_navigation_link_path(link), method: :put
      end

      down_link = if link.last?
        link_to icon(:arrow_down, color: "#eee !important"), "#", disabled: true
      else
        link_to icon(:arrow_down), down_admin_navigation_link_path(link), method: :put
      end

      safe_join [ up_link, down_link ]
    end
  end

  member_action :up, :method => :put do
    link = NavigationLink.find(params[:id])
    link.move_higher
    redirect_to({action: :index}, {notice: "Position is #{link.position}"})
  end

  member_action :down, :method => :put do
    link = NavigationLink.find(params[:id])
    link.move_lower
    redirect_to({action: :index}, {notice: "Position is #{link.position}"})
  end

end
