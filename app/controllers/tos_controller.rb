class TosController < ApplicationController
  before_filter :require_user

  def new
    @contribution = params[:contribution_id]

    respond_to do |format|
      if request.xhr?
        format.html { render :partial => 'tos_contribution_form', :layout => false }
      else
        format.html
      end
    end
  end

  def create
    reason = params[:tos][:reason]
    @contribution = Contribution.find(params[:contribution_id])
    if !reason.blank? && @contribution
      result = Tos.send_violation_complaint(current_person, @contribution, reason)
    end
    # Rails.logger.info("TOS Result:#{result}")

    respond_to do |format|
      unless reason.blank?
        @notice = "Thank you! You're helping to make Northeast Ohio stronger!"
        format.js
      else
        flash[:notice] = @error = "Please include a reason."
        format.js
      end
    end
  end

end
