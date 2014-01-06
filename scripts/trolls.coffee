module.exports = (robot) ->
  robot.respond /buy me/i, (msg) ->
    msg.reply "go buy it yourself!"

  robot.respond /make me (.+)/i, (msg) ->
    msg.reply "make yourself #{msg.match[1]}"
