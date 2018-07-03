require 'test_helper'

class WorkHourTest < ActiveSupport::TestCase
  setup do
    @work_hour = work_hours(:one)
  end

  test "unique index" do
    @new_work_hour = WorkHour.new({
      'project' => @work_hour.project,
      'date' => @work_hour.date,
      'hour' => @work_hour.hour
    })
    assert_not @new_work_hour.valid?
  end
end
