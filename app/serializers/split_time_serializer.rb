class SplitTimeSerializer < ActiveModel::Serializer
  attributes :id, :effort_id, :lap, :split_id, :bitkey, :time_from_start, :data_status, :pacer, :remarks
end