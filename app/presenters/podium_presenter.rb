# frozen_string_literal: true

class PodiumPresenter < BasePresenter

  attr_reader :event
  delegate :name, :course, :course_name, :organization, :organization_name, :to_param, :multiple_laps?,
           :event_group, :ordered_events_within_group, :start_time_local, to: :event
  delegate :available_live, :multiple_events?, to: :event_group

  def initialize(event, template, current_user)
    @event = event
    @template = template
    @current_user = current_user
  end

  def categories
    template&.results_categories
  end

  def template_name
    template&.name
  end

  def point_system?
    template&.point_system.present?
  end

  private

  attr_reader :template, :current_user
end
