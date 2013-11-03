_ = require 'underscore'

module.exports = (robot) ->
	robot.respond /reset beer clock (.*)/i, (msg) ->
		date = msg.match[1]
		unless date == " "
			newHappyHour = new Date(date)

			if newHappyHour.getHours() < 12
				msg.reply "Did you really mean to set happy hour to a time before noon? Remember to use a 24-hour time when setting the beer clock."

			else
				robot.brain.set 'happyHourStart', newHappyHour
				start = robot.brain.get 'happyHourStart'
				end = new Date(start.getTime() + 1000 * 60 * 389)
				robot.brain.set 'happyHourEnd', end
				msg.reply "Happy hour will start at #{robot.brain.get 'happyHourStart'} and end at #{robot.brain.get 'happyHourEnd'}"

		else
			msg.reply "Please tell the bot when happy hour is! 'bot reset beer clock mm/dd/yyyy hh:mm'"

	robot.respond /get beer clock/i, (msg) ->
		msg.reply "Happy hour will start at #{new Date(robot.brain.get 'happyHourStart')} and end at #{new Date(robot.brain.get 'happyHourEnd')}."

	robot.respond /beer (.*)/i, (msg) ->
  	msg.reply beerClock()

	beerClock = () ->
		now = new Date()
		
		# check storage of happy hour
		# if not there, set to the date and time of a known happy hour
		unless robot.brain.get 'happyHourStart' 
			robot.brain.set 'happyHourStart', new Date("10/25/2013 17:30")
		unless robot.brain.get 'happyHourEnd'
			robot.brain.set 'happyHourEnd', new Date("10/25/2013 23:59")

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
			return "Stop talking to me and go drink a beer!"
		
		# if it's not happy hour, return time to happy hour
		if now < happyHourStart
			timeToHappy = new Date (happyHourStart - now)
			return "Happy hour starts in #{formatTime(timeToHappy)}."

		else
			"Sorry. I don't know when happy hour is. Please try again."

	# format the time to h hours m minutes and s seconds until happy hour
	formatTime = (time) ->
		countdown = ""
		s = 1000
		m = s * 60
		h = m * 60
		d = h * 24

		days = Math.floor(time / d)
		unless days == 0
			countdown += "#{days} days "

		hours = Math.floor((time % d) / h)
		unless hours == 0
			countdown += "#{hours} hours "

		minutes = Math.floor((time % h) / m)
		unless minutes == 0
			countdown += "#{minutes} minutes "

		seconds = Math.floor((time % m) / s)
		unless seconds == 0
			countdown += "#{seconds} seconds"

		return countdown