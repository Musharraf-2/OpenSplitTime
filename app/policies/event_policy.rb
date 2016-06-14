class EventPolicy
  attr_reader :current_user, :model

  def initialize(current_user, model)
    @current_user = current_user
    @event = model
  end

  def new?
    @current_user.present?
  end

  def import_splits?
    @current_user.authorized_to_edit?(@event)
  end

  def import_efforts?
    @current_user.authorized_to_edit?(@event)
  end

  def edit?
    @current_user.authorized_to_edit?(@event)
  end

  def create?
    @current_user.present?
  end

  def update?
    @current_user.authorized_to_edit?(@event)
  end

  def destroy?
    @current_user.authorized_to_edit?(@event)
  end

  def stage?
    @current_user.authorized_to_edit?(@event)
  end

  def splits?
    @current_user.authorized_to_edit?(@event)
  end

  def associate_split?
    @current_user.authorized_to_edit?(@event)
  end

  def associate_splits?
    @current_user.authorized_to_edit?(@event)
  end

  def remove_split?
    @current_user.authorized_to_edit?(@event)
  end

  def remove_all_splits?
    @current_user.authorized_to_edit?(@event)
  end

  def create_participants?
    @current_user.authorized_to_edit?(@event)
  end

  def reconcile?
    @current_user.authorized_to_edit?(@event)
  end

  def delete_all_efforts?
    @current_user.authorized_to_edit?(@event)
  end

  def associate_participant?
    @current_user.authorized_to_edit?(@event)
  end

  def associate_participants?
    @current_user.authorized_to_edit?(@event)
  end

  def set_data_status?
    @current_user.authorized_to_edit?(@event)
  end

  def live_entry?
    @current_user.admin?
  end

  def progress_report?
    @current_user.admin?
  end

  def aid_station_report?
    @current_user.admin?
  end

  def get_event_data?
    @current_user.admin?
  end

  def get_live_effort_data?
    @current_user.admin?
  end

  def post_file_effort_data?
    @current_user.admin?
  end

  def set_times_data?
    @current_user.admin?
  end

  def aid_station_degrade?
    @current_user.admin?
  end

  def aid_station_advance?
    @current_user.admin?
  end

  def aid_station_detail?
    @current_user.admin?
  end

end
