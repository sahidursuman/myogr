module Admin
  module Salon
    class Employee

      include Mongoid::Document
      field :first_name, type: String
      field :last_name, type: String
      field :position, type: String
      field :specialization, type: String

      def avaliable_time(date)
        start_time = Time.parse (date + ' ' + Admin::Salon::Settings.schedule.mon.from)
        end_time = Time.parse date + ' ' + Admin::Salon::Settings.schedule.mon.till
        time_range = start_time.split_by 30.minutes, end_time
        plain_busy_time = busy_time(date).flatten << end_time
        avaliable_time = []
        time_range.chunk{
            |time| plain_busy_time.include? time
        }.each{
            |key, array| avaliable_time << array unless key
        }
        avaliable_time
      end

      def busy_time(date)
        busy_time = []
        day_records = Record.where(record_date: date, employee: self.id)
        day_records.each do |record|
          split_period = 30.minutes
          time = record.record_time + (record.total_duration).hours - split_period
          busy_time = busy_time + [record.record_time.localtime.split_by(30.minutes, time)]
        end
        busy_time
      end

    end
  end
end
