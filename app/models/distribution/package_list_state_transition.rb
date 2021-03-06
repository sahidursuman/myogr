module Distribution
  class PackageListStateTransition < ActiveRecord::Base
    self.table_name_prefix = 'distribution_'

    attr_accessible :package_list_id, :event, :from, :to, :created_at

    belongs_to :distribution_package_list, :class_name => 'Distribution::PackageList'
  end
end