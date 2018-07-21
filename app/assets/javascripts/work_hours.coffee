# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
window.draw_graph =(labels, data) ->
    if labels.length == data.length
        ctx = document.getElementById("workHourChart").getContext('2d')

        color = 'rgba(54, 162, 235, 0.2)'
        colors = []
        for i in [0..labels.length]
            colors.push(color)

        chart = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: labels,
                datasets: [{
                    label: 'WorkHours',
                    data: data,
                    backgroundColor: colors,
                    borderWidth: 1
                }]
            },
            options: {
                scales: {
                    yAxes: [{
                        ticks: {
                            beginAtZero:true
                        }
                    }]
                }
            }
        })
