require 'rails_helper'
include ActionDispatch::TestProcess

RSpec.describe EffortDataStatusSetter do
  let(:split_times_101) { FactoryGirl.build_stubbed_list(:split_times_in_out, 20, effort_id: 101).first(10) }
  let(:split_ids) { split_times_101.map(&:split_id).uniq }
  let(:split1) { FactoryGirl.build_stubbed(:start_split, id: split_ids[0], course_id: 10, distance_from_start: 0) }
  let(:split2) { FactoryGirl.build_stubbed(:split, id: split_ids[1], course_id: 10, distance_from_start: 1000) }
  let(:split3) { FactoryGirl.build_stubbed(:split, id: split_ids[2], course_id: 10, distance_from_start: 2000) }
  let(:split4) { FactoryGirl.build_stubbed(:split, id: split_ids[3], course_id: 10, distance_from_start: 3000) }
  let(:split5) { FactoryGirl.build_stubbed(:split, id: split_ids[4], course_id: 10, distance_from_start: 4000) }
  let(:split6) { FactoryGirl.build_stubbed(:finish_split, id: split_ids[5], course_id: 10, distance_from_start: 5000) }

  describe '#initialize' do
    it 'initializes with an effort and a times_calculator in an args hash' do
      effort = FactoryGirl.build_stubbed(:effort)
      times_calculator = instance_double(StatTimesCalculator)
      expect { EffortDataStatusSetter.new(effort: effort,
                                          times_calculator: times_calculator) }.not_to raise_error
    end

    it 'raises an ArgumentError if no effort is given' do
      times_calculator = instance_double(StatTimesCalculator)
      expect { EffortDataStatusSetter.new(times_calculator: times_calculator) }
          .to raise_error(/must include effort/)
    end
  end

  describe '#set_data_status' do
    context 'for an effort that has not yet started' do
      it 'sets effort data_status to nil and does not attempt to change split_times' do
        effort = Effort.new(first_name: 'John', last_name: 'Doe', gender: 'male', data_status: 2)
        times_calculator = instance_double(StatTimesCalculator)
        setter = EffortDataStatusSetter.new(effort: effort, times_calculator: times_calculator)
        setter.set_data_status
        expect(setter.changed_split_times).to eq([])
        expect(setter.changed_efforts).to eq([effort])
        expect(effort.data_status).to be_nil
      end
    end

    context 'for an effort partially underway or completed' do
      before do
        FactoryGirl.reload
      end

      let(:split_times_100) { FactoryGirl.build_stubbed_list(:split_times_hardrock_0, 10, effort_id: 100) }
      let(:split_times_101) { FactoryGirl.build_stubbed_list(:split_times_hardrock_1, 10, effort_id: 101) }
      let(:split_times_102) { FactoryGirl.build_stubbed_list(:split_times_hardrock_2, 10, effort_id: 102) }
      let(:split_times_103) { FactoryGirl.build_stubbed_list(:split_times_hardrock_3, 10, effort_id: 103) }
      let(:split_times_104) { FactoryGirl.build_stubbed_list(:split_times_hardrock_4, 10, effort_id: 104) }
      let(:split_times_105) { FactoryGirl.build_stubbed_list(:split_times_hardrock_5, 10, effort_id: 105) }
      let(:split_times_106) { FactoryGirl.build_stubbed_list(:split_times_hardrock_6, 10, effort_id: 106) }
      let(:split_times_107) { FactoryGirl.build_stubbed_list(:split_times_hardrock_7, 10, effort_id: 107) }
      let(:split_times_108) { FactoryGirl.build_stubbed_list(:split_times_hardrock_8, 10, effort_id: 108) }
      let(:split_times_109) { FactoryGirl.build_stubbed_list(:split_times_hardrock_9, 10, effort_id: 109) }
      let(:splits) { FactoryGirl.build_stubbed_list(:splits_hardrock_ccw, 16, course_id: 10) }
      let(:efforts) { FactoryGirl.build_stubbed_list(:efforts_hardrock, 10, event_id: 50) }

      it 'sets data_status of all split_times and effort to "good" when split_times fall within expected ranges' do
        n = 10
        split_times = [split_times_100.first(n), split_times_101.first(n), split_times_102.first(n),
                       split_times_103.first(n), split_times_104.first(n), split_times_105.first(n),
                       split_times_106.first(n), split_times_107.first(n), split_times_108.first(n),
                       split_times_109.first(n)].flatten
        container = SegmentTimesContainer.new(split_times: split_times)

        ordered_splits = splits
        similar_efforts = efforts
        times_calculator = StatTimesCalculator.new(ordered_splits: ordered_splits,
                                                   efforts: similar_efforts,
                                                   segment_times_container: container)

        effort = efforts.find { |effort| effort.id == 104 }
        effort_split_times = split_times_104.first(n)
        expect(effort).to receive(:ordered_splits).and_return(ordered_splits)
        setter = EffortDataStatusSetter.new(effort: effort,
                                            split_times: effort_split_times,
                                            times_calculator: times_calculator)
        setter.set_data_status
        expect(effort_split_times.map(&:data_status).uniq).to eq(['good'])
        expect(effort.data_status).to eq('good')
      end

      it 'sets data_status of starting split_time to "bad" if time_from_start is non-zero' do
        n = 5
        split_times = [split_times_100.first(n), split_times_101.first(n), split_times_102.first(n),
                       split_times_103.first(n), split_times_104.first(n), split_times_105.first(n),
                       split_times_106.first(n), split_times_107.first(n), split_times_108.first(n),
                       split_times_109.first(n)].flatten
        container = SegmentTimesContainer.new(split_times: split_times)

        ordered_splits = splits
        similar_efforts = efforts
        times_calculator = StatTimesCalculator.new(ordered_splits: ordered_splits,
                                                   efforts: similar_efforts,
                                                   segment_times_container: container)

        effort = efforts.find { |effort| effort.id == 104 }
        effort_split_times = split_times_104.first(n)
        effort_split_times[0].time_from_start = 100
        expect(effort).to receive(:ordered_splits).and_return(ordered_splits)
        setter = EffortDataStatusSetter.new(effort: effort,
                                            split_times: effort_split_times,
                                            times_calculator: times_calculator)
        setter.set_data_status
        expect(effort_split_times.map(&:data_status)).to eq(%w(bad good good good good))
        expect(effort.data_status).to eq('bad')
      end

      it 'sets data_status of intermediate split_times to "bad" if time_from_start is less than earlier time_from_start' do
        n = 5
        split_times = [split_times_100.first(n), split_times_101.first(n), split_times_102.first(n),
                       split_times_103.first(n), split_times_104.first(n), split_times_105.first(n),
                       split_times_106.first(n), split_times_107.first(n), split_times_108.first(n),
                       split_times_109.first(n)].flatten
        container = SegmentTimesContainer.new(split_times: split_times)

        ordered_splits = splits
        similar_efforts = efforts
        times_calculator = StatTimesCalculator.new(ordered_splits: ordered_splits,
                                                   efforts: similar_efforts,
                                                   segment_times_container: container)

        effort = efforts.find { |effort| effort.id == 104 }
        effort_split_times = split_times_104.first(n)
        effort_split_times[2].time_from_start = effort_split_times[1].time_from_start - 60
        effort_split_times[4].time_from_start = effort_split_times[3].time_from_start - 60
        expect(effort).to receive(:ordered_splits).and_return(ordered_splits)
        setter = EffortDataStatusSetter.new(effort: effort,
                                            split_times: effort_split_times,
                                            times_calculator: times_calculator)
        setter.set_data_status
        expect(effort_split_times.map(&:data_status)).to eq(%w(good good bad good bad))
        expect(effort.data_status).to eq('bad')
      end

      it 'sets data_status of intermediate split_times to "bad" if time_from_start is impossibly too short' do
        n = 5
        split_times = [split_times_100.first(n), split_times_101.first(n), split_times_102.first(n),
                       split_times_103.first(n), split_times_104.first(n), split_times_105.first(n),
                       split_times_106.first(n), split_times_107.first(n), split_times_108.first(n),
                       split_times_109.first(n)].flatten
        container = SegmentTimesContainer.new(split_times: split_times)

        ordered_splits = splits
        similar_efforts = efforts
        times_calculator = StatTimesCalculator.new(ordered_splits: ordered_splits,
                                                   efforts: similar_efforts,
                                                   segment_times_container: container)

        effort = efforts.find { |effort| effort.id == 104 }
        effort_split_times = split_times_104.first(n)
        effort_split_times[1].time_from_start = effort_split_times[0].time_from_start + 1000
        effort_split_times[3].time_from_start = effort_split_times[2].time_from_start + 1000
        expect(effort).to receive(:ordered_splits).and_return(ordered_splits)
        setter = EffortDataStatusSetter.new(effort: effort,
                                            split_times: effort_split_times,
                                            times_calculator: times_calculator)
        setter.set_data_status
        expect(effort_split_times.map(&:data_status)).to eq(%w(good bad good bad good))
        expect(effort.data_status).to eq('bad')
      end

      it 'sets data_status of intermediate split_times to "bad" if time_from_start is impossibly too long' do
        n = 4
        split_times = [split_times_100.first(n), split_times_101.first(n), split_times_102.first(n),
                       split_times_103.first(n), split_times_104.first(n), split_times_105.first(n),
                       split_times_106.first(n), split_times_107.first(n), split_times_108.first(n),
                       split_times_109.first(n)].flatten
        container = SegmentTimesContainer.new(split_times: split_times)

        ordered_splits = splits
        similar_efforts = efforts
        times_calculator = StatTimesCalculator.new(ordered_splits: ordered_splits,
                                                   efforts: similar_efforts,
                                                   segment_times_container: container)

        effort = efforts.find { |effort| effort.id == 104 }
        effort_split_times = split_times_104.first(n)
        effort_split_times[3].time_from_start = effort_split_times[2].time_from_start + 24.hours
        expect(effort).to receive(:ordered_splits).and_return(ordered_splits)
        setter = EffortDataStatusSetter.new(effort: effort,
                                            split_times: effort_split_times,
                                            times_calculator: times_calculator)
        setter.set_data_status
        expect(effort_split_times.map(&:data_status)).to eq(%w(good good good bad))
        expect(effort.data_status).to eq('bad')
      end

      it 'sets data_status of intermediate split_times to "questionable" if time_from_start is probably too short' do
        n = 4
        split_times = [split_times_100.first(n), split_times_101.first(n), split_times_102.first(n),
                       split_times_103.first(n), split_times_104.first(n), split_times_105.first(n),
                       split_times_106.first(n), split_times_107.first(n), split_times_108.first(n),
                       split_times_109.first(n)].flatten
        container = SegmentTimesContainer.new(split_times: split_times)

        ordered_splits = splits
        similar_efforts = efforts
        times_calculator = StatTimesCalculator.new(ordered_splits: ordered_splits,
                                                   efforts: similar_efforts,
                                                   segment_times_container: container)

        effort = efforts.find { |effort| effort.id == 104 }
        effort_split_times = split_times_104.first(n)
        effort_split_times[3].time_from_start = effort_split_times[2].time_from_start + 1.hours
        expect(effort).to receive(:ordered_splits).and_return(ordered_splits)
        setter = EffortDataStatusSetter.new(effort: effort,
                                            split_times: effort_split_times,
                                            times_calculator: times_calculator)
        setter.set_data_status
        expect(effort_split_times.map(&:data_status)).to eq(%w(good good good questionable))
        expect(effort.data_status).to eq('questionable')
      end

      it 'sets data_status of intermediate split_times to "questionable" if time_from_start is probably too long' do
        n = 4
        split_times = [split_times_100.first(n), split_times_101.first(n), split_times_102.first(n),
                       split_times_103.first(n), split_times_104.first(n), split_times_105.first(n),
                       split_times_106.first(n), split_times_107.first(n), split_times_108.first(n),
                       split_times_109.first(n)].flatten
        container = SegmentTimesContainer.new(split_times: split_times)

        ordered_splits = splits
        similar_efforts = efforts
        times_calculator = StatTimesCalculator.new(ordered_splits: ordered_splits,
                                                   efforts: similar_efforts,
                                                   segment_times_container: container)

        effort = efforts.find { |effort| effort.id == 104 }
        effort_split_times = split_times_104.first(n)
        effort_split_times[3].time_from_start = effort_split_times[2].time_from_start + 5.hours
        expect(effort).to receive(:ordered_splits).and_return(ordered_splits)
        setter = EffortDataStatusSetter.new(effort: effort,
                                            split_times: effort_split_times,
                                            times_calculator: times_calculator)
        setter.set_data_status
        expect(effort_split_times.map(&:data_status)).to eq(%w(good good good questionable))
        expect(effort.data_status).to eq('questionable')
      end

      it 'sets looks past bad or questionable times to determine validity of later split_times' do
        n = 10
        split_times = [split_times_100.first(n), split_times_101.first(n), split_times_102.first(n),
                       split_times_103.first(n), split_times_104.first(n), split_times_105.first(n),
                       split_times_106.first(n), split_times_107.first(n), split_times_108.first(n),
                       split_times_109.first(n)].flatten
        container = SegmentTimesContainer.new(split_times: split_times)

        ordered_splits = splits
        similar_efforts = efforts
        times_calculator = StatTimesCalculator.new(ordered_splits: ordered_splits,
                                                   efforts: similar_efforts,
                                                   segment_times_container: container)

        effort = efforts.find { |effort| effort.id == 104 }
        effort_split_times = split_times_104.first(n)
        effort_split_times[7].time_from_start = effort_split_times[6].time_from_start + 1.minute
        effort_split_times[8].time_from_start = effort_split_times[7].time_from_start + 1.minute

        # Much too long from [8] to [9] but reasonable from [6] to [9]
        effort_split_times[9].time_from_start = effort_split_times[8].time_from_start + 5.hours
        expect(effort).to receive(:ordered_splits).and_return(ordered_splits)
        setter = EffortDataStatusSetter.new(effort: effort,
                                            split_times: effort_split_times,
                                            times_calculator: times_calculator)
        setter.set_data_status
        expect(effort_split_times.map(&:data_status)).to eq(%w(good good good good good good good bad bad good))
        expect(effort.data_status).to eq('bad')
      end

      it 'works properly for an effort on the fast end of the spectrum of available efforts with all good times' do
        n = 10
        split_times = [split_times_100.first(n), split_times_101.first(n), split_times_102.first(n),
                       split_times_103.first(n), split_times_104.first(n), split_times_105.first(n),
                       split_times_106.first(n), split_times_107.first(n), split_times_108.first(n),
                       split_times_109.first(n)].flatten
        container = SegmentTimesContainer.new(split_times: split_times)

        ordered_splits = splits
        similar_efforts = efforts
        times_calculator = StatTimesCalculator.new(ordered_splits: ordered_splits,
                                                   efforts: similar_efforts,
                                                   segment_times_container: container)

        effort = efforts.find { |effort| effort.id == 109 }
        effort_split_times = split_times_109.first(n)
        expect(effort).to receive(:ordered_splits).and_return(ordered_splits)
        setter = EffortDataStatusSetter.new(effort: effort,
                                            split_times: effort_split_times,
                                            times_calculator: times_calculator)
        setter.set_data_status
        expect(effort_split_times.map(&:data_status).uniq).to eq(['good'])
        expect(effort.data_status).to eq('good')
      end

      it 'works properly for an effort on the slow end of the spectrum of available efforts with all good times' do
        n = 10
        split_times = [split_times_100.first(n), split_times_101.first(n), split_times_102.first(n),
                       split_times_103.first(n), split_times_104.first(n), split_times_105.first(n),
                       split_times_106.first(n), split_times_107.first(n), split_times_108.first(n),
                       split_times_109.first(n)].flatten
        container = SegmentTimesContainer.new(split_times: split_times)

        ordered_splits = splits
        similar_efforts = efforts
        times_calculator = StatTimesCalculator.new(ordered_splits: ordered_splits,
                                                   efforts: similar_efforts,
                                                   segment_times_container: container)

        effort = efforts.find { |effort| effort.id == 100 }
        effort_split_times = split_times_100.first(n)
        expect(effort).to receive(:ordered_splits).and_return(ordered_splits)
        setter = EffortDataStatusSetter.new(effort: effort,
                                            split_times: effort_split_times,
                                            times_calculator: times_calculator)
        setter.set_data_status
        expect(effort_split_times.map(&:data_status).uniq).to eq(['good'])
        expect(effort.data_status).to eq('good')
      end

      it 'works properly for an effort on the fast end of the spectrum of available efforts with some bad times' do
        n = 10
        split_times = [split_times_100.first(n), split_times_101.first(n), split_times_102.first(n),
                       split_times_103.first(n), split_times_104.first(n), split_times_105.first(n),
                       split_times_106.first(n), split_times_107.first(n), split_times_108.first(n),
                       split_times_109.first(n)].flatten
        container = SegmentTimesContainer.new(split_times: split_times)

        ordered_splits = splits
        similar_efforts = efforts
        times_calculator = StatTimesCalculator.new(ordered_splits: ordered_splits,
                                                   efforts: similar_efforts,
                                                   segment_times_container: container)

        effort = efforts.find { |effort| effort.id == 109 }
        effort_split_times = split_times_109.first(n)
        effort_split_times[7].time_from_start = effort_split_times[6].time_from_start + 1.minute
        effort_split_times[8].time_from_start = effort_split_times[7].time_from_start + 1.minute

        # Much too long from [8] to [9] but reasonable from [6] to [9]
        effort_split_times[9].time_from_start = effort_split_times[8].time_from_start + 4.hours
        expect(effort).to receive(:ordered_splits).and_return(ordered_splits)
        setter = EffortDataStatusSetter.new(effort: effort,
                                            split_times: effort_split_times,
                                            times_calculator: times_calculator)
        setter.set_data_status
        expect(effort_split_times.map(&:data_status)).to eq(%w(good good good good good good good bad bad good))
        expect(effort.data_status).to eq('bad')
      end

      it 'works properly for an effort on the slow end of the spectrum of available efforts with some bad times' do
        n = 10
        split_times = [split_times_100.first(n), split_times_101.first(n), split_times_102.first(n),
                       split_times_103.first(n), split_times_104.first(n), split_times_105.first(n),
                       split_times_106.first(n), split_times_107.first(n), split_times_108.first(n),
                       split_times_109.first(n)].flatten
        container = SegmentTimesContainer.new(split_times: split_times)

        ordered_splits = splits
        similar_efforts = efforts
        times_calculator = StatTimesCalculator.new(ordered_splits: ordered_splits,
                                                   efforts: similar_efforts,
                                                   segment_times_container: container)

        effort = efforts.find { |effort| effort.id == 100 }
        effort_split_times = split_times_100.first(n)
        effort_split_times[7].time_from_start = effort_split_times[6].time_from_start + 1.minute
        effort_split_times[8].time_from_start = effort_split_times[7].time_from_start + 1.minute

        # Much too long from [8] to [9] but reasonable from [6] to [9]
        effort_split_times[9].time_from_start = effort_split_times[8].time_from_start + 6.hours
        expect(effort).to receive(:ordered_splits).and_return(ordered_splits)
        setter = EffortDataStatusSetter.new(effort: effort,
                                            split_times: effort_split_times,
                                            times_calculator: times_calculator)
        setter.set_data_status
        expect(effort_split_times.map(&:data_status)).to eq(%w(good good good good good good good bad bad good))
        expect(effort.data_status).to eq('bad')
      end

      it 'works properly for a full effort with multiple problems' do
        n = 10
        split_times = [split_times_100.first(n), split_times_101.first(n), split_times_102.first(n),
                       split_times_103.first(n), split_times_104.first(n), split_times_105.first(n),
                       split_times_106.first(n), split_times_107.first(n), split_times_108.first(n),
                       split_times_109.first(n)].flatten
        container = SegmentTimesContainer.new(split_times: split_times)

        ordered_splits = splits
        similar_efforts = efforts
        times_calculator = StatTimesCalculator.new(ordered_splits: ordered_splits,
                                                   efforts: similar_efforts,
                                                   segment_times_container: container)

        effort = efforts.find { |effort| effort.id == 105 }
        effort_split_times = split_times_105.first(n)
        effort_split_times[0].time_from_start = -60 # Non-zero start time
        effort_split_times[2].time_from_start = effort_split_times[1].time_from_start - 1.minute # Negative time in aid
        effort_split_times[4].time_from_start = effort_split_times[3].time_from_start + 26.hours # Too long in aid
        effort_split_times[7].time_from_start = effort_split_times[6].time_from_start + 20.minutes # Too short for segment
        effort_split_times[9].time_from_start = effort_split_times[8].time_from_start + 10.hours # Too long for segment

        expect(effort).to receive(:ordered_splits).and_return(ordered_splits)
        setter = EffortDataStatusSetter.new(effort: effort,
                                            split_times: effort_split_times,
                                            times_calculator: times_calculator)
        setter.set_data_status
        expect(effort_split_times.map(&:data_status)).to eq(%w(bad good bad good bad good good bad good bad))
        expect(effort.data_status).to eq('bad')
      end

      it 'works properly for a full effort with multiple problems and not enough data for statistical limits' do
        n = 10
        split_times = [split_times_100.first(n), split_times_101.first(n), split_times_102.first(n),
                       split_times_103.first(n), split_times_104.first(n), split_times_105.first(n)].flatten
        container = SegmentTimesContainer.new(split_times: split_times)

        ordered_splits = splits
        similar_efforts = efforts
        times_calculator = StatTimesCalculator.new(ordered_splits: ordered_splits,
                                                   efforts: similar_efforts,
                                                   segment_times_container: container)

        effort = efforts.find { |effort| effort.id == 105 }
        effort_split_times = split_times_105.first(n)
        effort_split_times[0].time_from_start = -60 # Non-zero start time
        effort_split_times[2].time_from_start = effort_split_times[1].time_from_start - 1.minute # Negative time in aid
        effort_split_times[4].time_from_start = effort_split_times[3].time_from_start + 26.hours # Too long in aid
        effort_split_times[7].time_from_start = effort_split_times[6].time_from_start + 20.minutes # Too short for segment
        effort_split_times[9].time_from_start = effort_split_times[8].time_from_start + 10.hours # Too long for segment

        expect(effort).to receive(:ordered_splits).and_return(ordered_splits)
        setter = EffortDataStatusSetter.new(effort: effort,
                                            split_times: effort_split_times,
                                            times_calculator: times_calculator)
        setter.set_data_status
        expect(effort_split_times.map(&:data_status)).to eq(%w(bad good bad good bad good good bad good bad))
        expect(effort.data_status).to eq('bad')
      end

      it 'if effort has a dropped_split_id, sets data_status of all split_times beyond that point to "bad"' do
        n = 10
        split_times = [split_times_100.first(n), split_times_101.first(n), split_times_102.first(n),
                       split_times_103.first(n), split_times_104.first(n), split_times_105.first(n),
                       split_times_106.first(n), split_times_107.first(n), split_times_108.first(n),
                       split_times_109.first(n)].flatten
        container = SegmentTimesContainer.new(split_times: split_times)

        ordered_splits = splits
        similar_efforts = efforts
        times_calculator = StatTimesCalculator.new(ordered_splits: ordered_splits,
                                                   efforts: similar_efforts,
                                                   segment_times_container: container)

        effort = efforts.find { |effort| effort.id == 104 }
        effort.dropped_split_id = ordered_splits[2].id
        effort_split_times = split_times_104.first(n)
        expect(effort).to receive(:ordered_splits).and_return(ordered_splits)
        setter = EffortDataStatusSetter.new(effort: effort,
                                            split_times: effort_split_times,
                                            times_calculator: times_calculator)
        setter.set_data_status
        expect(effort_split_times.map(&:data_status)).to eq(%w(good good good good good bad bad bad bad bad))
        expect(effort.data_status).to eq('bad')
      end
    end

    describe '#changed_split_times and #changed_efforts' do
      before do
        FactoryGirl.reload
      end

      let(:split_times_100) { FactoryGirl.build_stubbed_list(:split_times_hardrock_0, 10, effort_id: 100) }
      let(:split_times_101) { FactoryGirl.build_stubbed_list(:split_times_hardrock_1, 10, effort_id: 101) }
      let(:split_times_102) { FactoryGirl.build_stubbed_list(:split_times_hardrock_2, 10, effort_id: 102) }
      let(:split_times_103) { FactoryGirl.build_stubbed_list(:split_times_hardrock_3, 10, effort_id: 103) }
      let(:split_times_104) { FactoryGirl.build_stubbed_list(:split_times_hardrock_4, 10, effort_id: 104) }
      let(:split_times_105) { FactoryGirl.build_stubbed_list(:split_times_hardrock_5, 10, effort_id: 105) }
      let(:split_times_106) { FactoryGirl.build_stubbed_list(:split_times_hardrock_6, 10, effort_id: 106) }
      let(:split_times_107) { FactoryGirl.build_stubbed_list(:split_times_hardrock_7, 10, effort_id: 107) }
      let(:split_times_108) { FactoryGirl.build_stubbed_list(:split_times_hardrock_8, 10, effort_id: 108) }
      let(:split_times_109) { FactoryGirl.build_stubbed_list(:split_times_hardrock_9, 10, effort_id: 109) }
      let(:splits) { FactoryGirl.build_stubbed_list(:splits_hardrock_ccw, 16, course_id: 10) }
      let(:efforts) { FactoryGirl.build_stubbed_list(:efforts_hardrock, 10, event_id: 50) }

      it 'returns an array containing split_times whose data_status was changed' do
        n = 5
        split_times = [split_times_100.first(n), split_times_101.first(n), split_times_102.first(n),
                       split_times_103.first(n), split_times_104.first(n), split_times_105.first(n),
                       split_times_106.first(n), split_times_107.first(n), split_times_108.first(n),
                       split_times_109.first(n)].flatten
        container = SegmentTimesContainer.new(split_times: split_times)

        ordered_splits = splits
        similar_efforts = efforts
        times_calculator = StatTimesCalculator.new(ordered_splits: ordered_splits,
                                                   efforts: similar_efforts,
                                                   segment_times_container: container)

        effort = efforts.find { |effort| effort.id == 104 }
        effort_split_times = split_times_104.first(n)
        effort_split_times[0].data_status = 2
        effort_split_times[1].data_status = 2
        effort_split_times[2].data_status = 2
        expect(effort_split_times[0]).to receive(:changed?).and_return(false)
        expect(effort_split_times[1]).to receive(:changed?).and_return(false)
        expect(effort_split_times[2]).to receive(:changed?).and_return(false)
        expect(effort).to receive(:ordered_splits).and_return(ordered_splits)
        setter = EffortDataStatusSetter.new(effort: effort,
                                            split_times: effort_split_times,
                                            times_calculator: times_calculator)
        setter.set_data_status
        expect(setter.changed_split_times).to eq(effort_split_times[3..4])
        expect(setter.changed_efforts).to eq([effort])
      end
    end
  end
end