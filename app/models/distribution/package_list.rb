module Distribution
  class PackageList < ::Schedule
    include Mongoid::Document

    field :package_limit, type: Integer
    field :is_closed, type: Boolean, default: false
    field :closed_by, type: String
    field :state, type:String, default: :forming

    has_many :packages, class_name: 'Distribution::Package', inverse_of: :package_list

    belongs_to :point, class_name: 'Distribution::Point', inverse_of: :package_lists

    attr_accessible :package_limit, :is_closed, :closed_by

    def closed?
      self.is_closed
    end

  end
end
