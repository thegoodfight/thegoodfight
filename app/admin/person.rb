ActiveAdmin.register Person do
  index do
    column :name
    column :appearances
    column :title
    column :created_at
    column :organization
    default_actions
  end

  form html: { multipart: true } do |f|
    f.inputs "Guest Details" do
      f.input :name
      f.input :title
      f.input :organization
      f.input :website
      f.input :twitter
      f.input :facebook
      f.input :image, as: :file
      f.input :description, as: :html_editor
    end
    f.actions
  end
end