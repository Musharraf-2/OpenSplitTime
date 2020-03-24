# frozen_string_literal: true

class EventSerializer < BaseSerializer
  attributes :id, :course_id, :organization_id, :name, :start_time, :home_time_zone, :start_time_local,
             :start_time_in_home_zone, :concealed, :laps_required, :maximum_laps, :multi_lap, :slug, :short_name,
             :multiple_sub_splits, :parameterized_split_names, :split_names
  link(:self) { api_v1_event_path(object) }

  has_many :efforts
  has_many :splits
  has_many :aid_stations
  belongs_to :course
  belongs_to :event_group

  # Included for backward compatibility
  def start_time_in_home_zone
    object.start_time_local
  end

  def multi_lap
    object.multiple_laps?
  end

  def concealed
    object.event_group.concealed?
  end

  def multiple_sub_splits
    object.multiple_sub_splits?
  end

  def parameterized_split_names
    object.splits.map(&:parameterized_base_name)
  end

  def split_names
    object.splits.map(&:base_name)
  end
end
