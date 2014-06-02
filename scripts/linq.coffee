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


  setSession = (res, callback)->
    cookieObj = parseCookie(res)
    robot.brain.data.linqSession = cookieObj._linqs_session
    callback()
    undefined

  logInBot = () ->
      # Sign In Hubot to Linqs, i.e. post the following
    #   hubot = { user: {
    #             email: "rahul@gmail.com", 
    #             password: "12345678"}
    #           }


    options = 
              method: 'POST'
              host: 'localhost'
              port: 3000
              path: '/users/sign_in?user[email]=rahul@gmail.com&user[password]=12345678' 

    req = http.request options, (res) ->
      setSession res, ()-> 
        undefined
    req.end() 

  formatLinks = (rawLinks)->
    _.reduce rawLinks, (memo, link)->
      "#{memo} \n #{link.title}: #{link.url}"
    , ""

  findLinks = (msg, linkTag) ->
    msg.http("http://localhost:3000/links.json")
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
    tags = urlAndTags[1]

    newLink = link: {}
    newLink.link = url: url, link_tags_attributes: {}, title: "hubotLink"
    newLink.link.link_tags_attributes = _.map tags.split(/\s+/), (tag) ->
      {tag_attributes: {name: tag}}


    msg.http("http://localhost:3000/links.json")
      .query(newLink)
      .headers( "_linqs_session": robot.brain.data.linqSession || "blah")
      .post() (err, res, body) ->
        logInBot()
        msg.http("http://localhost:3000/links.json")
        .query(newLink)
        .headers( "_linqs_session": robot.brain.data.linqSession)
        .post() (err, res, body) ->
          console.log(body)
    
                

     



     

