express = require 'express'
fs = require 'fs'
mongojs = require 'mongojs'

app = express()

app.configure () ->
    app.set 'views', __dirname + '/views'
    app.set 'view engine', 'jade'

app.get '/', (req, res) ->
    display res, 'movies'

app.get '/tv', (req, res) ->
    display res, 'tvs'


display = (res, collectionName) ->
    db = mongojs 'pirate_db'
    collection = db.collection collectionName

    collection.find().sort({leechers: -1}).limit 100, (err, docs) ->
        res.render 'index', {data: docs}
        db.close()


app.listen 9000
console.log 'listenning on 9000'
