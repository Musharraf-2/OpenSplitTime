require 'rails_helper'

RSpec.describe ETL::Transformers::AdilasBearStrategy do
  subject { ETL::Transformers::AdilasBearStrategy.new(struct, options) }
  let(:struct) { OpenStruct.new(attributes) }
  let(:attributes) { {full_name: 'Linda McFadden', bib_number: '187', gender: 'F', age: '54', city: 'Modesto', state_code: 'CA', times: times} }
  let(:times) { ['9/23/2016 6:00:00 am', '9/23/2016 8:49:10 am',
                 '9/23/2016 8:49:10 am', '9/23/2016 12:30:27 pm',
                 '9/23/2016 12:30:29 pm', '9/24/2016 1:49:11 pm',
                 '9/23/2016 1:49:11 pm', '... ...'] }
  let(:options) { {event: event} }
  let(:proto_records) { subject.transform }
  let(:first_proto_record) { proto_records.first }

  let(:event) { build_stubbed(:event, course: course) }
  let(:course) { build_stubbed(:course) }
  let(:start) { build_stubbed(:start_split, course: course, base_name: 'Start') }
  let(:logan) { build_stubbed(:split, course: course, base_name: 'Logan', sub_split_bitmap: 65, distance_from_start: 17220) }
  let(:leatham) { build_stubbed(:split, course: course, base_name: 'Leatham', sub_split_bitmap: 65, distance_from_start: 31704) }
  let(:richards) { build_stubbed(:split, course: course, base_name: 'Richards', sub_split_bitmap: 65, distance_from_start: 36210) }
  let(:splits) { [start, logan, leatham, richards] }
  before do
    allow(course).to receive(:splits).and_return(splits)
    allow(event).to receive(:splits).and_return(splits)
  end

  describe '#transform' do
    it 'returns a single ProtoRecord parent' do
      expect(proto_records.size).to eq(1)
      expect(first_proto_record).to be_a(ProtoRecord)
    end

    it 'transforms effort headers to match the database' do
      expect(first_proto_record.to_h.keys.sort)
          .to match_array(%i(age bib_number event_id first_name gender last_name start_offset city state_code))
    end

    it 'returns genders transformed to "male" or "female"' do
      expect(first_proto_record[:gender]).to eq('female')
    end

    it 'splits full names into first names and last names' do
      expect(first_proto_record[:first_name]).to eq('Linda')
      expect(first_proto_record[:last_name]).to eq('McFadden')
    end

    it 'assigns event.id to :event_id key' do
      expect(first_proto_record[:event_id]).to eq(event.id)
    end

    it 'sorts split headers and returns an array of children' do
      records = first_proto_record.children
      time_points = event.required_time_points
      expect(records.size).to eq(7)
      expect(records.map(&:record_type)).to eq([:split_time] * records.size)
      expect(records.map { |pr| pr[:lap] }).to eq(time_points.map(&:lap))
      expect(records.map { |pr| pr[:split_id] }).to eq(time_points.map(&:split_id))
      expect(records.map { |pr| pr[:sub_split_bitkey] }).to eq(time_points.map(&:bitkey))
      expect(records.map { |pr| pr[:time_from_start] }).to eq([0.0, 10150.0, 10150.0, 23427.0, 23429.0, 114551.0, 28151.0])
    end

    it 'sets [:stopped_here] attribute on the final child record' do
      records = first_proto_record.children
      expect(records.reverse.find { |pr| pr[:time_from_start].present? }[:stopped_here]).to eq(true)
      expect(records.map { |pr| pr[:stopped_here] }).to eq([nil, nil, nil, nil, nil, nil, true])
    end
  end
end
