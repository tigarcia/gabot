url = require 'url'
_ = require 'underscore'

module.exports = (robot) ->
  robot.hear /((([A-Za-z]{3,9}:(?:\/\/)?)(?:[-;:&=\+\$,\w]+@)?[A-Za-z0-9.-]+|(?:www.|[-;:&=\+\$,\w]+@)[A-Za-z0-9.-]+)((?:\/[\+~%\/.\w-_]*)?\??(?:[-\+=&;%@.\w_]*)#?(?:[.\!\/\\w]*))?)/i, (msg) ->
    link = url.parse msg.match[0]

    # we only care about gists right now
    if link.host == 'gist.github.com'
      # no duplicates
      return if _.any robot.brain.data.gists, (gist) -> url.format(gist.link) == url.format(link)

      # make sure we have storage available
      robot.brain.data.gists ?= []

      # store that bad boy
      robot.brain.data.gists.push
        link: link
        id: _.last(robot.brain.data.gists)?.id + 1 || 0

      console.log "Stored a gist"
      msg.reply "Stored that gist with id #{_.last(robot.brain.data.gists).id}"

  robot.respond /delete gist ([0-9]+)/i, (msg) ->
    id = msg.match[1]
    robot.brain.data.gists = _.filter robot.brain.data.gists, (gist) ->
      gist.id != parseInt id
    msg.reply "Deleted gist with id = #{id}"


  robot.router.get '/gists', (req, res) ->
    res.setHeader 'Content-Type', 'text/html'
    _.each robot.brain.data.gists, (gist) ->
      res.write "#{gist.id}"
      res.write '&nbsp;'
      res.write url.format gist.link
      res.write '<br/>'

    res.end()
