module Distribution
  class PackageStateTransition
    include Mongoid::Document
    field :event, type: String
    field :from, type: String
    field :to, type: String
    field :created_at, type: Time
    embedded_in :package
  end
end