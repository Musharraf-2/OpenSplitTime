# https://github.com/plataformatec/devise/wiki/How-To:-redirect-to-a-specific-page-on-successful-sign-in

module Users
  class RegistrationsController < Devise::RegistrationsController
    before_action :protect_from_spam, only: [:create, :update]

    # GET /resource/sign_up
    def new
      build_resource(pre_filled_params)
      yield resource if block_given?
      respond_with resource
    end

    protected

    def after_sign_up_path_for(resource)
      signed_in_root_path(resource)
    end

    def after_update_path_for(resource)
      signed_in_root_path(resource)
    end

    private

    def protect_from_spam
      # username is a honeypot field
      # timestamp contains seconds from epoch at the time the form was loaded
      redirect_to root_path if params[:username].present? || random_generated_names?

      return unless ::OstConfig.timestamp_bot_detection?

      redirect_to root_path if params[:timestamp].blank?

      form_fill_duration = Time.current.to_i - params[:timestamp].to_i
      redirect_to root_path if form_fill_duration < 10.seconds
    end

    def random_generated_names?
      first_name = params.dig(:user, :first_name) || ""
      last_name = params.dig(:user, :last_name) || ""

      first_name.length > 7 &&
        last_name.length > 7 &&
        [first_name.downcase, first_name.upcase, first_name.titleize].exclude?(first_name) &&
        [last_name.downcase, last_name.upcase, last_name.titleize].exclude?(last_name)
    end

    def pre_filled_params
      params[:user]&.permit(*UserParameters.permitted) || {}
    end

    def sign_up_params
      params.require(:user).permit(*UserParameters.permitted)
    end

    def account_update_params
      params.require(:user).permit(*(UserParameters.permitted << :current_password))
    end
  end
end
