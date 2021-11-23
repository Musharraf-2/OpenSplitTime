# frozen_string_literal: true

class PartnerPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def post_initialize
    end
  end

  attr_reader :partner

  def post_initialize(partner)
    @partner = partner
  end

  def create?
    user.authorized_to_edit?(partner.event_group)
  end

  def edit?
    user.authorized_to_edit?(partner.event_group)
  end

  def update?
    user.authorized_to_edit?(partner.event_group)
  end

  def destroy?
    user.authorized_to_edit?(partner.event_group)
  end
end
