# frozen_string_literal: true

class CourseGroupFinishersController < ApplicationController
  before_action :authenticate_user!, except: [:index]
  before_action :set_course_group
  before_action :set_organization

  # GET /organizations/:organization_id/course_groups/:course_group_id/finishers
  def index
    @presenter = ::CourseGroupFinishersDisplay.new(@course_group, view_context)

    respond_to do |format|
      format.html
      format.json do
        finishers = @presenter.filtered_finishers
        html = params[:html_template].present? ? render_to_string(partial: params[:html_template], formats: [:html], collection: finishers) : ""
        render json: { course_group_finishers: finishers, html: html, links: { next: @presenter.next_page_url } }
      end
    end
  end

  # POST /organizations/:organization_id/course_groups/:course_group_id/finishers/export_async
  def export_async
    @presenter = ::CourseGroupFinishersDisplay.new(@course_group, view_context)
    uri = URI(request.referrer)
    source_url = [uri.path, uri.query].compact.join("?")
    sql_string = @presenter.filtered_finishers_unpaginated.to_sql

    export_job = current_user.export_jobs.new(
      controller_name: controller_name,
      resource_class_name: "CourseGroupFinisher",
      source_url: source_url,
      sql_string: sql_string,
      status: :waiting,
    )

    if export_job.save
      ::ExportAsyncJob.perform_later(export_job.id)
      flash[:success] = "Export in progress."
      redirect_to export_jobs_path
    else
      flash[:danger] = "Unable to create export job: #{export_job.errors.full_messages.join(', ')}"
      redirect_to request.referrer || export_jobs_path, status: :unprocessable_entity
    end
  end

  private

  def params_class
    ::CourseGroupFinisherParameters
  end

  def set_course_group
    @course_group = ::CourseGroup.friendly.find(params[:course_group_id])
  end

  def set_organization
    @organization = ::Organization.friendly.find(params[:organization_id])
  end
end