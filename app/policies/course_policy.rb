class CoursePolicy
  attr_reader :current_user, :course

  def initialize(current_user, course)
    @current_user = current_user
    @course = course
  end

  def new?
    current_user.present?
  end

  def edit?
    current_user.authorized_to_edit?(course)
  end

  def create?
    current_user.present?
  end

  def update?
    current_user.authorized_to_edit?(course)
  end

  def destroy?
    current_user.admin? # Course destruction could affect events that belong to users other than the course owner
  end

  def segment_picker?
    current_user.present?
  end

  def plan_effort?
    current_user.present?
  end

end
