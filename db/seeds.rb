require 'date'

# Create test account
User.create(email: 'test@example.com', password: 'password')

# Create test work_hour data
projects = %w(aaa bbb ccc)
work_hours = []
init_date = Date.new(2018, 1, 1)
for index in 0..100 do
  hour = rand(12) + 1
  work_hours.push({
    project: projects.sample,
    date: init_date + index,
    hour: hour
  })
end
WorkHour.create(work_hours)
