class WorkHour < ApplicationRecord
  validates :project, uniqueness: { scope: [:date] }
end
