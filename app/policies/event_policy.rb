# frozen_string_literal: true

class EventPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def post_initialize
    end

    def authorized_to_edit_records
      scope.delegated_to(user)
    end

    def authorized_to_view_records
      scope.visible_or_delegated_to(user)
    end
  end

  attr_reader :event

  def post_initialize(event)
    @event = event
  end

  def spread?
    user.present?
  end

  def summary?
    user.authorized_to_edit?(event)
  end

  def import?
    user.authorized_to_edit?(event)
  end

  def delete_all_efforts?
    user.authorized_fully?(event)
  end

  def set_stops?
    user.authorized_to_edit?(event)
  end

  def edit_start_time?
    user.admin?
  end

  def update_start_time?
    user.admin?
  end

  def reassign?
    user.authorized_fully?(event)
  end

  def export?
    user.authorized_to_edit?(event)
  end

  def aid_station_detail?
    user.authorized_to_edit?(event)
  end

  def preview_lottery_sync?
    user.authorized_to_edit?(event)
  end

  def preview_sync?
    user.authorized_to_edit?(event)
  end

  def sync_lottery_entrants?
    preview_lottery_sync?
  end

  def sync_entrants?
    preview_sync?
  end

  # Policies for live namespace

  def progress_report?
    user.authorized_to_edit?(event)
  end

  def aid_station_report?
    user.authorized_to_edit?(event)
  end

  # Policies for staging namespace

  def get_countries?
    user.present?
  end

  def get_time_zones?
    user.present?
  end

  def get_locations?
    user.authorized_to_edit?(event)
  end

  def event_staging_app?
    user.authorized_to_edit?(event)
  end

  def post_event_course_org?
    user.authorized_to_edit?(event)
  end

  def update_event_visibility?
    user.authorized_to_edit?(event)
  end

  def new_staging?
    user.present?
  end
end
