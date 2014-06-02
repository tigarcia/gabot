linkMe = undefined
linkMe = undefined
module.exports = (robot) ->
  robot.respond /(linq2|l2)( me)? (.*)/i, (msg) ->
    imageMe msg, msg.match[3], (url) ->
      msg.send url



linkMe = (msg, query, cb) ->
  msg.http("http://ajax.googleapis.com/ajax/services/search/images").query(q).get() (err, res, body) ->
    image = undefined
    images = undefined
    _ref = undefined
    image = undefined
    images = undefined
    _ref = undefined
    images = JSON.parse(body)
    images = ((if (_ref = images.responseData) isnt null then _ref.results else undefined))
    if ((if images isnt null then images.length else undefined)) > 0
      image = msg.random(images)
      cb "" + image.unescapedUrl + "#.png"
