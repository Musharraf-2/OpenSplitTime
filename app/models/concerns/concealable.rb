# frozen_string_literal: true

# Used for models with a 'concealed' attribute.

# Not used on the Effort module, which needs custom logic entirely based on the
# associated event's concealed status.

module Concealable
  extend ActiveSupport::Concern

  included do
    scope :concealed, -> { where(concealed: true) }
    scope :visible, -> { where(concealed: false) }
  end

  def visible?
    !concealed?
  end

  alias_method :visible, :visible?
end
