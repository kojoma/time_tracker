class HomeController < ApplicationController
  require 'date'

  before_action :authenticate_user!

  def index
    today = Date.today
    @work_summary_list = get_work_summary(today.year, today.month)
    @summary_total_hour = @work_summary_list.map { |item| item[:hour] }.sum()
  end

  private
    def get_work_summary(year, month)
      work_hours = WorkHour.search({:year => year, :month => month})

      hash = {}
      work_hours.each do |work_hour|
        unless hash.has_key?(work_hour.project)
          hash[work_hour.project] = 0
        end
        hash[work_hour.project] += work_hour.hour
      end

      summary_list = []
      hash.each do |key, val|
        summary_list << {:project => key, :hour => val}
      end

      summary_list
    end
end
