# frozen_string_literal: true

module Interactors
  class MatchRawTimesToSplitTimes
    include Interactors::Errors

    def self.perform!(args)
      new(args).perform!
    end

    def initialize(args)
      ArgsValidator.validate(params: args, required: [:event_group, :raw_times], exclusive: [:event_group, :raw_times, :tolerance], class: self.class)
      @event_group = args[:event_group]
      @raw_times = args[:raw_times]
      @tolerance = args[:tolerance] || 1.minute
      @split_times = event_group.split_times.with_time_record_matchers
      @errors = []
      validate_setup
    end

    def perform!
      if errors.present?
        Interactors::Response.new(errors, "Raw times could not be matched. ")
      else
        response = Interactors::MatchTimeRecordsToSplitTimes.perform!(time_records: matchable_raw_times, split_times: split_times, tolerance: tolerance)
        response.resources[:unmatched] += unmatchable_raw_times
        response
      end
    end

    private

    attr_reader :event_group, :raw_times, :tolerance, :split_times, :errors
    
    def matchable_raw_times
      RawTime.where(id: raw_times).with_relation_ids
    end

    # RawTime.with_relation_ids will not return RawTimes that have no matching bib_number or split_name
    # So we need to go back and get them to include them in resources[:unmatched]

    def unmatchable_raw_times
      RawTime.where(id: unmatchable_ids)
    end

    def unmatchable_ids
      raw_times.map(&:id) - matchable_raw_times.map(&:id)
    end

    def validate_setup
      errors << raw_time_mismatch_error unless raw_times.all? { |rt| rt.event_group_id == event_group.id }
    end
  end
end