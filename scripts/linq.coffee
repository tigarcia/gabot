# Description:
#   A way to receive and send links to the linqs app
#
# Commands:
#   hubot link me <url> <tags> 
#   hubot grab me <tag> 

_  = require 'underscore'
http = require 'http'


module.exports = (robot) ->

  robot.brain.data.linqSession ?= null

  parseCookie = (res)->
    cookieHeader= res.headers['set-cookie']
    cookieString = cookieHeader[1]
   
    cookieObj = {}
    cookieArr = cookieString.split(/\;\s+/)
    _.each cookieArr, (str)->
      keyVal = str.split("=")
      cookieObj[keyVal[0]] = keyVal[1] || null

    cookieObj


  setSession = (res)->
    cookieObj = parseCookie(res)
    robot.brain.data.linqSession = cookieObj._linqs_session
    
         
    undefined

  logInBot = (msg, callback) ->
    # Sign In Hubot to Linqs, i.e. post the following
    #   hubot = { user: {
    #             email: ENV[HUBOT_USERNAME], 
    #             password: ENV[HUBOT_PASSWORD]}
    #           }


    options = 
              method: 'POST'
              host: 'localhost'
              port: 3000
              path: '/users/sign_in?user[email]=#{ENV[HUBOT_USERNAME]}&user[password]=#{ENV[HUBOT_PASSWORD]}' 

    req = http.request options, (res) ->
      setSession res
    req.end() 

    callback()


  formatLinks = (rawLinks)->
    _.reduce rawLinks, (memo, link)->
      "#{memo} \n #{link.title}: #{link.url}"
    , ""

  findLinks = (msg, linkTag) ->
    msg.http("http://linqs.herokuapp.com//links.json")
      .get() (err, res, body) ->
        results = JSON.parse(body).links;
        rawLinks = _.filter results, (link) ->
          link.title == linkTag
        msg.send formatLinks(rawLinks)

  
  robot.respond /grab( me)? (.*)/i, (msg) ->
    linkTag = msg.match[2]
    findLinks(msg, linkTag)


  robot.respond /(link|l)( me)? (.*)/i, (msg) ->
    urlAndTags = msg.match[3].split(/\s+/)
    url = urlAndTags[0]
    urlAndTags.shift()
    tags = urlAndTags.join(" ")

    linkTitle = "hubotLink"
    linkUrl = url
    encodedTags = encodeURIComponent(tags)
    
    postLinqs = ()->
      paramStr = "link[title]=#{linkTitle}"
      paramStr += "&link[url]=#{linkUrl}"
      paramStr += "&link[link_tags_attributes][0][tag_attributes][name]=#{encodedTags}"
      msg.http("http://linqs.herokuapp.com//links.json?"+ paramStr)
      .headers( cookie: "_linqs_session="+ robot.brain.data.linqSession, "Accept": "application/json")
      .post() (err, res, body) ->
        console.log("Message Sent")

    logInBot(msg, postLinqs)

    
                

     



     

