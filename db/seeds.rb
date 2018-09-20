require 'date'
work_hours = []
init_date = Date.new(2018, 1, 1)
for index in 0..100 do
  hour = rand(12) + 1
  work_hours.push({
    project: 'test',
    date: init_date + index,
    hour: hour
  })
end
WorkHour.create(work_hours)
