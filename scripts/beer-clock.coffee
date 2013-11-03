# Description:
#   Beer clock allows a user to set, get, and know the countdown until happy hour
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot reset beer clock (*) - Reset the happy hour start and end to a specific time
#   hubot get beer clock - Check the currently stored happy hour start and end
#		hubot beer (*) - Get the countdown to the next happy hour (or a snarky response). Automatically reset beer clock one week in future if current happy hour has passed.


_ = require 'underscore'

module.exports = (robot) ->
	robot.respond /reset beer clock (.*)/i, (msg) ->
		date = msg.match[1]
		newHappyHour = new Date(date)

		# if date not valid, let a user know to pass in a proper date
		if isNaN(newHappyHour.getTime()) == true
			msg.reply "That's not a valid date! Reset the beer clock by typing 'bot reset beer clock mm/dd/yyyy hh:mm'"

		# otherwise, reset the date
		else
			# alert people of 24-hour format if they type 5:30
			if newHappyHour.getHours() < 12
				msg.reply "Did you really mean to set happy hour to a time before noon? Remember to use a 24-hour time when setting the beer clock."

			# if proper date and time, reset the beer clock
			else
				robot.brain.set 'happyHourStart', newHappyHour
				start = robot.brain.get 'happyHourStart'
				end = new Date(start.getTime() + 1000 * 60 * 389)
				robot.brain.set 'happyHourEnd', end
				msg.reply "Happy hour will start at #{robot.brain.get 'happyHourStart'} and end at #{robot.brain.get 'happyHourEnd'}"

	# send back stored times if user asks for them
	robot.respond /get beer clock/i, (msg) ->
		msg.reply "Happy hour will start at #{new Date(robot.brain.get 'happyHourStart')} and end at #{new Date(robot.brain.get 'happyHourEnd')}."

	# respond to 'beer <whatever>' with beer countdown
	robot.respond /beer (.*)/i, (msg) ->
		now = new Date()
		
		# check storage of happy hour
		# if not there, set to the date and time of a known happy hour
		unless robot.brain.get 'happyHourStart' 
			robot.brain.set 'happyHourStart', new Date("10/25/2013 17:30")
		unless robot.brain.get 'happyHourEnd'
			robot.brain.set 'happyHourEnd', new Date("10/25/2013 23:59")

		# set local variables to stored times
		happyHourStart = new Date(robot.brain.get 'happyHourStart')
		happyHourEnd = new Date(robot.brain.get 'happyHourEnd')

		# if the current happy hour has passed, reset it to one week in the future
		# keep doing that until happy hour is in the future
		# store new dates
		if now > happyHourEnd
			until happyHourEnd > now
				happyHourStart.setTime(happyHourStart.getTime() + 7 * 24 * 60 * 60 * 1000)
				happyHourEnd.setTime(happyHourEnd.getTime() + 7 * 24 * 60 * 60 * 1000)
			robot.brain.set 'happyHourStart', happyHourStart
			robot.brain.set 'happyHourEnd', happyHourEnd

		# if it's currently happy hour, stop talking to the bot!
		if now > happyHourStart && now < happyHourEnd
			msg.reply "Stop talking to me and go drink a beer!"
		
		# if it's not happy hour, return time to happy hour
		if now < happyHourStart
			timeToHappy = new Date (happyHourStart - now)
			msg.reply "Happy hour starts in #{formatTime(timeToHappy)}."

		# if for some reason it hits the fan...
		else
			msg.reply "Sorry. I don't know when happy hour is. Please try 'bot reset beer clock mm/dd/yyyy hh:mm' to set the beer clock."

	# format the time to h hours m minutes and s seconds until happy hour
	formatTime = (time) ->
		countdown = ""
		s = 1000
		m = s * 60
		h = m * 60
		d = h * 24

		# calculate days, hours, minutes, seconds and add to response string if greater than 0
		# for each, add singular if time equals 1, plural if greater than 1

		days = Math.floor(time / d)
		unless days == 0
			countdown += "#{days} #{if days == 1 then "day" else "days"}, "

		hours = Math.floor((time % d) / h)
		unless hours == 0
			countdown += "#{hours} #{if hours == 1 then "hour" else "hours"}, "

		minutes = Math.floor((time % h) / m)
		unless minutes == 0
			countdown += "#{minutes} #{if minutes == 1 then "minute" else "minutes"}, "

		seconds = Math.floor((time % m) / s)
		unless seconds == 0
			countdown += "#{seconds} #{if seconds == 1 then "second" else "seconds"}"

		return countdown