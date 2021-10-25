# frozen_string_literal: true

module ImportJobsHelper
  def import_job_status_component(import_job)
    return unless import_job.status?

    status_colors = {
      waiting: "black",
      :extracting => "pink",
      :transforming => "yellow",
      :loading => "cyan",
      finished: "green",
      failed: "red"
    }.with_indifferent_access

    content_tag(:div) do
      label = " #{import_job.status.titleize}"
      icon = fa_icon("circle", style: "color:#{status_colors[import_job.status]}")
      icon + label
    end
  end

  def pretty_duration(seconds)
    return "--:--" unless seconds.present?

    parse_string = seconds < 3600 ? "%M:%S" : "%H:%M:%S"
    Time.at(seconds).utc.strftime(parse_string)
  end
end
