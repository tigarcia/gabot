_ = require 'underscore'

module.exports = (robot) ->
  students = require "#{process.env.PWD}/filez/students.json"

  robot.brain.data.students_without_partners ?= []
  robot.brain.data.student_pairs ?= []

  #Put the names of all of the students in an array
  for i in students
    student = i['name']
    robot.brain.data.students_without_partners.push(student)

  robot.respond /p(air)? me up/i, (msg) ->
    name = msg.message.user.name
    if _.contains(robot.brain.data.students_without_partners, name)
      temp = _.without(robot.brain.data.students_without_partners, student)
      partner = _.sample(temp)
      msg.send "I have assigned #{partner} as your partner!"
      robot.brain.data.student_pairs.push(student)
      robot.brain.data.student_pairs.push(partner)
      robot.brain.data.students_without_partners = _.without(robot.brain.data.students_without_partners,student, partner)
    else
      msg.send "You already have a partner!"

  robot.respond /d pair me/i, (msg) ->
    name = msg.message.user.name
    index = _.indexOf(robot.brain.data.student_pairs, name)
    if index != -1
      if index %2 == 1
        partner = robot.brain.data.student_pairs[index-1]

        robot.brain.data.student_pairs =_.without(robot.brain.data.student_pairs, name, partner)
      if index %2 == 0
        partner = robot.brain.data.student_pairs[index+1]
        robot.brain.data.student_pairs =_.without(robot.brain.data.student_pairs, name, partner)
      robot.brain.data.students_without_partners.push(student)
      robot.brain.data.students_without_partners.push(partner)
      msg.send "I have broken you and #{partner} up!"
    else
      msg.send "You don't have a partner!"