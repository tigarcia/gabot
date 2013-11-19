url = require 'url'
_ = require 'underscore'
request = require 'request'

bootstrapify = (res) ->
  res.write '<link rel="stylesheet" href="http://netdna.bootstrapcdn.com/bootstrap/3.0.0/css/bootstrap.min.css"></link>'
  res.write '<script src="http://netdna.bootstrapcdn.com/bootstrap/3.0.0/js/bootstrap.min.js"></script>'

module.exports = (robot) ->
  robot.hear /((([A-Za-z]{3,9}:(?:\/\/)?)(?:[-;:&=\+\$,\w]+@)?[A-Za-z0-9.-]+|(?:www.|[-;:&=\+\$,\w]+@)[A-Za-z0-9.-]+)((?:\/[\+~%\/.\w-_]*)?\??(?:[-\+=&;%@.\w_]*)#?(?:[.\!\/\\w]*))?)/i, (msg) ->
    return if msg.message.text.match /nosave/
    link = url.parse msg.match[0]

    # we only care about gists right now
    if link.host == 'gist.github.com'
      # no duplicates
      return if _.any robot.brain.data.gists, (gist) -> url.format(gist.link) == url.format(link)

      # make sure we have storage available
      robot.brain.data.gists ?= []

      request.get "#{msg.match[0]}.json", (err, res, body) ->
        if err
          msg.reply "There was an error processing that gist: #{err}"
        else
          data = JSON.parse body

          # store that bad boy
          robot.brain.data.gists.push
            link: link
            id: (_.last(robot.brain.data.gists)?.id + 1) || 0
            description: data.description
            user: msg.message.user.mention_name || msg.message.user.name

          msg.reply "Stored that gist with id #{_.last(robot.brain.data.gists).id}"

  robot.respond /delete gist ([0-9]+)/i, (msg) ->
    id = msg.match[1]
    robot.brain.data.gists = _.filter robot.brain.data.gists, (gist) ->
      gist.id != parseInt id
    msg.reply "Deleted gist with id = #{id}"

  robot.respond /fetch gist descriptions/i, (msg) ->
    msg.reply "Ok, I'll do that right now."
    _.each robot.brain.data.gists, (gist) ->
      unless gist.description
        request.get "#{url.format gist.link}.json", (err, res, body) ->
          unless err
            gist.description = (JSON.parse body).description
          else
            console.log "Error fetching gist description: #{err}"

  robot.router.get '/gists', (req, res) ->
    res.setHeader 'Content-Type', 'text/html'
    bootstrapify res
    res.write '<style> span { margin-right: 5px} </style>'
    res.write '<div class="list-group">'
    _.each robot.brain.data.gists, (gist) ->
      link = url.format gist.link
      res.write '<div class="list-group-item">'
      res.write "<span class=\"gist-id\">#{gist.id}</span>"
      res.write "<span class=\"gist-link\"><a href=\"#{link}\">#{link}</a></span>"
      res.write "<span class=\"gist-description\">#{gist.description || 'No Description'}</span>"
      res.write "<span class=\"gist-user\">#{gist.user || 'Nobody'}</span>"
      res.write '</div>'

    res.write '</div>'
    res.end()
