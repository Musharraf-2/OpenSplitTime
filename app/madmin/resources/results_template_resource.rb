class ResultsTemplateResource < Madmin::Resource
  # Attributes
  attribute :id, form: false
  attribute :identifier
  attribute :name
  attribute :aggregation_method
  attribute :podium_size
  attribute :point_system
  attribute :slug
  attribute :created_by
  attribute :updated_by
  attribute :created_at, form: false
  attribute :updated_at, form: false

  # Associations
  attribute :slugs
  attribute :organization
  attribute :results_template_categories
  attribute :results_categories

  # Uncomment this to customize the display name of records in the admin area.
  # def self.display_name(record)
  #   record.name
  # end

  # Uncomment this to customize the default sort column and direction.
  # def self.default_sort_column
  #   "created_at"
  # end
  #
  # def self.default_sort_direction
  #   "desc"
  # end
end
