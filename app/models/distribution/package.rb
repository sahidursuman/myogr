# encoding: utf-8
module Distribution
  class Package < ActiveRecord::Base
    include Tenacity

    self.table_name_prefix = 'distribution_'

    ACTIVE_STATES = :accepted, :collecting, :collected, :in_distribution
    FINAL_STATES = :issued, :utilized
    METHODS = :at_point, :case, :delivery
    #TODO в настройки
    METHODS_IDENTIFICATOR = {at_point: '', case: 'К', delivery: 'Д'}

    before_create :set_order

    attr_accessible :user_id, :items_attributes, :collector_id, :collection_date, :distribution_method, :document_number

    validates :document_number, presence: true, length: {minimum: 5, maximum: 12}

    t_belongs_to :user
    belongs_to :package_list, class_name: 'Distribution::PackageList'
    has_many :items, class_name: 'Distribution::PackageItem'

    accepts_nested_attributes_for :items, allow_destroy: true

    scope :in_states, lambda {|states_array| where{state.in states_array.map(&:to_s)} }
    scope :not_in_states, lambda {|states_array| where{state.not_in states_array.map(&:to_s)} }
    scope :active, self.where(state: ACTIVE_STATES.map(&:to_s))
    scope :case, where(distribution_method: 'case')
    scope :not_case, where{distribution_method.not_eq 'case'}
    scope :distribution_method, ->(method_name) { where(distribution_method: method_name.to_s) }

    state_machine :state, :initial => :accepted do
      store_audit_trail
      event :start_collecting do
        transition :accepted => :collecting
      end

      before_transition :on => :finish_collecting do |package|
        package.collection_date = Time.now
      end
      event :finish_collecting do
        transition :collecting => :collected
      end
      event :to_distribution do
        transition :collected => :in_distribution
      end
      event :to_issued do
        transition [:collected, :in_distribution] => :issued
      end
      event :utilize do
        transition [:collected, :in_distribution] => :utilized
      end

      state :accepted do
        def changeable?
          true
        end
      end

      state all - :accepted do
        def changeable?
          false
        end
      end

      state :accepted, :collecting do
        def collected?
          false
        end
      end

      state all - [:accepted, :collecting] do
        def collected?
          true
        end
      end

      state :issued, :utilized do
        def completed?
          true
        end
      end

      state all - [:issued, :utilized] do
        def completed?
          false
        end
      end
    end

    include StateMachineScopes
    state_machine_scopes

    def active?
      ACTIVE_STATES.include? self.state.to_sym
    end

    def case?
      self.distribution_method.eql?('case')
    end

    def collect!(collector, collected_items)
      self.collector_id = collector
      self.items.each do |item|
        item.collected if !collected_items.include?(item.item_id)
      end
      #TODO уточнить, нужно ли хранить дату последнего или всех обновлений заказов
      self.finish_collecting if self.can_finish_collecting?
    end

    def set_order
      return if self.package_list.nil?
      order_num = self.package_list.order_number_for(self.distribution_method)
      self.order = order_num
      self.code = order_num.to_s + METHODS_IDENTIFICATOR[self.distribution_method.to_sym]
    end
  end
end
