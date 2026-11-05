module Admin
  # Change the admin password (replaces Devise's registrations/edit page).
  class AccountsController < BaseController
    def edit
      set_meta(title: "Account", description: "Admin")
      render inertia: "admin/account", props: { email: current_user.email }
    end

    def update
      if current_user.update_with_password(params.require(:account).permit(:current_password, :password, :password_confirmation))
        bypass_sign_in(current_user)
        redirect_to admin_root_path, notice: "Password updated."
      else
        redirect_to edit_admin_account_path, inertia: { errors: current_user.errors.to_hash(true).transform_values(&:to_sentence) }
      end
    end
  end
end
