ActiveAdmin.register Person do
  index do
    column :name
    column :appearances
    column :title
    column :email
    column :created_at
    column :organization
    default_actions
  end

  form html: { multipart: true } do |f|
    f.inputs "Guest Details" do
      f.input :name
      f.input :email
      f.input :title
      f.input :organization
      f.input :website, hint: "Full URL, including http://"
      f.input :twitter, hint: "Just the username - no http, no @ symbol"
      f.input :facebook, hint: "Just the username - no http"
      f.input :public_email, hint: "Optional - will be shown on site if provided."
      f.input :image, as: :file
      f.input :description, as: :html_editor
    end
    f.actions
  end
end
