class WorkHour < ApplicationRecord
  require 'date'

  validates :project, uniqueness: { scope: [:date] }

  DEFAULT_PAGE = 1

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

      page = params[:page].present? ? params[:page] : DEFAULT_PAGE

      WorkHour.where(hash).order(:date).page(page)
    else
      WorkHour.page(DEFAULT_PAGE)
    end
  end
end
