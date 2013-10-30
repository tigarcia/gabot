_ = require 'underscore'

module.exports = (robot) ->
  students = require "#{process.env.PWD}/filez/students.json"
  snakes = _.select students, (student) -> student.team == 'snakes'
  camels = _.select students, (student) -> student.team == 'camels'

  robot.respond /student list me/i, (msg) ->
    msg.send _.map students, (student) -> student.name

  robot.respond /student me/i, (msg) ->
    msg.send "I choose #{_.sample(students).name}"

  robot.respond /snake me/i, (msg) ->
    msg.send "I choose #{_.sample(snakes).name}"

  robot.respond /camel me/i, (msg) ->
    msg.send "I choose #{_.sample(camels).name}"
