fs = require 'fs'
{join} = require 'path'
express = require 'express'
bodyParser = require 'body-parser'
app = express()
http = require('http').Server(app)
{exec} = require 'child_process'

PORT = 8000
OPEN_BROWSER = false
COMMENTS_FILE = join __dirname, 'comments.json'

app.use express.static 'public'
app.use bodyParser.json()
app.use bodyParser.urlencoded extended: true
app.use (req, res, next) ->
  res.setHeader 'Access-Control-Allow-Origin', '*'
  res.setHeader 'Cache-Control', 'no-cache'
  next()

app.get '/api/comments', (req, res) ->
  fs.readFile COMMENTS_FILE, (err, data) ->
    if err
      console.error err
      process.exit 1
    else
      res.json JSON.parse data

app.post '/api/comments', (req, res) ->
  fs.readFile COMMENTS_FILE, (err, data) ->
    if err
      console.error err
      process.exit 1
    else
      comments = JSON.parse data
      newComment =
        id: Date.now()
        author: req.body.author
        text: req.body.text
      comments.push newComment
      fs.writeFile COMMENTS_FILE, JSON.stringify(comments, null, 4), (err) ->
        if err
          console.error err
          process.exit 1
        else
          res.json comments

http.listen PORT, -> console.log "Listening on #{PORT}"

exec "open http://localhost:#{PORT}" if OPEN_BROWSER
