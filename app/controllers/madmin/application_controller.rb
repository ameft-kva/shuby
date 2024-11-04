module Madmin
  class ApplicationController < Madmin::BaseController
    include Rails.application.routes.url_helpers

    before_action :authenticate_admin_user
    around_action :without_tenant if defined? ActsAsTenant

    impersonates :user

    def authenticate_admin_user
      redirect_to root_path unless current_user&.admin?
    end

    def without_tenant
      ActsAsTenant.without_tenant do
        yield
      end
    end
  end
end
