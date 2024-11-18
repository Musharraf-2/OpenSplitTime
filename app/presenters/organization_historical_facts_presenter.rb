# frozen_string_literal: true

class OrganizationHistoricalFactsPresenter < OrganizationPresenter

  attr_reader :request

  def initialize(organization, view_context)
    super
    @request = view_context.request
  end

  def historical_facts
    organization.historical_facts
  end

  def historical_facts_count
    historical_facts.size
  end

  def filtered_historical_facts
    return @filtered_historical_facts if defined?(@filtered_historical_facts)

    @filtered_historical_facts = historical_facts.where(filter_hash).search(search_text)
        .select { |fact| matches_criteria?(fact) }
        .paginate(page: page, per_page: per_page)
    @filtered_historical_facts.each do |fact|
      fact.person = fact.person_id? ? indexed_people[fact.person_id] : nil
      fact.event = fact.event_id? ? indexed_events[fact.event_id] : nil
      fact.creator = fact.created_by? ? indexed_users[fact.created_by] : nil
    end
  end

  def filtered_historical_facts_count
    filtered_historical_facts.size
  end

  def filtered_historical_facts_unpaginated_count
    filtered_historical_facts.total_entries
  end

  def next_page_url
    view_context.url_for(request.params.merge(page: page + 1)) if filtered_historical_facts_count == per_page
  end

  def kind
    params.filter[:kind] || "All Kinds"
  end

  private

  def indexed_people
    @indexed_efforts ||= Person.where(id: person_ids).index_by(&:id)
  end

  def indexed_events
    @indexed_events ||= organization.events.index_by(&:id)
  end

  def indexed_users
    @indexed_users ||= User.where(id: user_ids).index_by(&:id)
  end

  def person_ids
    @person_ids ||= filtered_historical_facts.map(&:person_id).compact.uniq
  end

  def user_ids
    @user_ids ||= filtered_historical_facts.map(&:created_by).compact.uniq
  end

  def matches_criteria?(fact)
    return true unless params[:kind].present?

    fact.kind.in?(params[:kind])
  end
end