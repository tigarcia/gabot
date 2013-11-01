module.exports = (robot) ->
	robot.respond /beer me/i, (msg) ->
  	msg.reply beerClock()

	robot.respond /current time/i, (msg) ->
		msg.reply currentTime()

	currentTime = () ->
 		now = new Date()
 		return "It's currently #{formatDate(now)}"

 	beerClock = () ->
 		happyHour = new Date("11/8/2013 17:30")
 		nextWeek = new Date()
 		nextWeek.setDate(happyHour.getDate() + 7)
 		nextWeek.setHours(17,30)
 		return "Happy hour is at #{formatDate(happyHour)}. Next week it will be at #{formatDate(nextWeek)}"

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