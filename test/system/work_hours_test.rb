require "application_system_test_case"

class WorkHoursTest < ApplicationSystemTestCase
  setup do
    @work_hour = work_hours(:one)
  end

  test "visiting the index" do
    visit work_hours_url
    assert_selector "h1", text: "Work Hours"
  end

  test "creating a Work hour" do
    visit work_hours_url
    click_on "New Work Hour"

    fill_in "Date", with: @work_hour.date
    fill_in "Hour", with: @work_hour.hour
    fill_in "Name", with: @work_hour.name
    click_on "Create Work hour"

    assert_text "Work hour was successfully created"
    click_on "Back"
  end

  test "updating a Work hour" do
    visit work_hours_url
    click_on "Edit", match: :first

    fill_in "Date", with: @work_hour.date
    fill_in "Hour", with: @work_hour.hour
    fill_in "Name", with: @work_hour.name
    click_on "Update Work hour"

    assert_text "Work hour was successfully updated"
    click_on "Back"
  end

  test "destroying a Work hour" do
    visit work_hours_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Work hour was successfully destroyed"
  end
end
