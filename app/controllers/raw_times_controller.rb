class RawTimesController < ApplicationController
  include BackgroundNotifiable

  before_action :set_raw_time

  def update
    authorize @raw_time

    if @raw_time.update(permitted_params)
      report_raw_times_available(@raw_time.event_group)
    else
      flash[:danger] = "Raw time could not be updated.\n#{@raw_time.errors.full_messages.join("\n")}"
    end
    redirect_to request.referrer
  end

  def destroy
    authorize @raw_time

    @raw_time.destroy
    respond_to do |format|
      format.html { redirect_to request.referrer }
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@raw_time) }
    end
  end

  private

  def set_raw_time
    @raw_time = RawTime.find(params[:id])
  end
end
