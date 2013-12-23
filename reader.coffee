mongojs = require 'mongojs'

db = mongojs 'pirate_db', ['movies']

db.movies.find().sort {leechers: -1}, (err, docs) ->
    for doc in docs
        console.log doc

    db.close()
