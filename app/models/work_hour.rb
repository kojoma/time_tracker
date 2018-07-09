class WorkHour < ApplicationRecord
  require 'date'

  validates :project, uniqueness: { scope: [:date] }

  def self.search(params)
    if params.present?
      hash = {}

      if params[:project].present?
        hash[:project] = params[:project]
      end

      if params[:year].present? || params[:month].present?
        if params[:year].present? && params[:month].present?
          start_date = Date.new(params[:year].to_i, params[:month].to_i, 1)
          end_date = Date.new(params[:year].to_i, params[:month].to_i, -1)
          hash[:date] = Range.new(start_date, end_date)
        else
          start_date = Date.new(params[:year].to_i, 1, 1)
          end_date = Date.new(params[:year].to_i, 12, -1)
          hash[:date] = Range.new(start_date, end_date)
        end
      end

      WorkHour.where(hash).order(:date).all
    else
      WorkHour.all
    end
  end
end
