module FeatureMacros
  def create_hardrock_event
    owner = create(:user)
    steward = create(:user)
    course = create(:course)
    splits = create_list(:splits_hardrock_ccw, 16, course: course)
    organization = create(:organization)
    organization.stewards << steward
    event_group = create(:event_group, concealed: false, created_by: owner.id, organization: organization)
    event = create(:event, course: course, event_group: event_group, home_time_zone: 'Mountain Time (US & Canada)', start_time_in_home_zone: '2016-07-01 06:00')
    event.splits << splits
    efforts = create_list(:effort, 8, :with_birthdate, event: event)
    create_list(:split_times_hardrock_31, 30, effort: efforts[0])
    create_list(:split_times_hardrock_33, 30, effort: efforts[1])
    create_list(:split_times_hardrock_35, 30, effort: efforts[2])
    create_list(:split_times_hardrock_36, 30, effort: efforts[3])
    create_list(:split_times_hardrock_38, 30, effort: efforts[4])
    create_list(:split_times_hardrock_41, 30, effort: efforts[5])
    create_list(:split_times_hardrock_43, 15, effort: efforts[6])
    create_list(:split_times_hardrock_45, 0, effort: efforts[7])
  end

  def clean_up_database
    SplitTime.delete_all
    Effort.delete_all
    AidStation.delete_all
    Split.delete_all
    Event.delete_all
    EventGroup.delete_all
    Course.delete_all
    Stewardship.delete_all
    User.delete_all
    Organization.delete_all
    Subscription.delete_all
    Person.delete_all
  end
end
