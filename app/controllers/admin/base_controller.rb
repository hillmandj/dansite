# Everything under /admin requires the signed-in admin.
module Admin
  class BaseController < InertiaController
    before_action :authenticate_user!
  end
end
