module.exports = (robot) ->
  robot.respond /buy me/i, (msg) ->
    msg.reply "go buy it yourself!"
