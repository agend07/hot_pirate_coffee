express = require 'express'
fs = require 'fs'
mongojs = require 'mongojs'

app = express()

app.configure () ->
    app.set 'views', __dirname + '/views'
    app.set 'view engine', 'jade'


app.get '/', (req, res) ->

    # fetch data from file
    # fs.readFile __dirname + '/data.json', 'utf8', (err, data) ->
    #     res.render 'index', {data: JSON.parse(data)}

    # fetch data from mongodb
    db = mongojs 'mongodb://localhost/pirate_db', ['movies']

    db.movies.find().sort({leechers: -1}).limit 40, (err, docs) ->
        res.render 'index', {data: docs}
        db.close()


app.listen 9000
console.log 'listenning on 9000'
