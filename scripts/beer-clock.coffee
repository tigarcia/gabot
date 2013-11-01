module.exports = (robot) ->
	robot.respond /beer me/i, (msg) ->
  	msg.reply beerClock()

	robot.respond /current time/i, (msg) ->
		msg.reply currentTime()

	currentTime = () ->
 		now = new Date()
 		return "It's currently #{formatDate(now)}"

 	beerClock = () ->
 		happyHour = new Date("10/18/2013 17:30")
 		now = new Date()
 		if now > happyHour
 			until happyHour > now
 				happyHour.setTime(happyHour.getTime() + 7 * 24 * 60 * 60 * 1000)
 		return "Happy hour is at #{formatDate(happyHour)}."


	formatDate = (date) ->
	  year = date.getFullYear()
	  month = forceTwoDigits(date.getMonth()+1)
	  day = forceTwoDigits(date.getDate())
	  hour = forceTwoDigits(date.getHours())
	  minute = forceTwoDigits(date.getMinutes())
	  second = forceTwoDigits(date.getSeconds())
	  return "#{hour}:#{minute} on #{month}/#{day}/#{year}"

	forceTwoDigits = (val) ->
	  if val < 10
	    return "0#{val}"
	  return val