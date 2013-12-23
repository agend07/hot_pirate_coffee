async = require 'async'
request = require 'request'
cheerio = require 'cheerio'
_ = require 'underscore'
fs = require 'fs'
mongojs = require 'mongojs'
program = require 'commander'

program
    .version('0.0.1')
    .option('-c, --collection [name]', 'Mongo collection name', 'movies')
    .option('-n, --number [nr]', 'Pirate page nr [201]', '201')
    .parse process.argv

# example usage:
# coffee fetch.coffee -n 201 -c movies - this one is default
# coffee fetch.coffee -n 205 -c tvs

processPage = (address, callback) ->

    request address, (error, response, body) ->

        if not error and response.statusCode is 200

            result = []

            $ = cheerio.load body

            $('table#searchResult tr').slice(2, 32).each -> 

                $row = $(this)

                result.push
                    title: $row.find('td div.detName a').text().trim()
                    link: 'http://thepiratebay.com' + $row.find('td div.detName a').attr('href')
                    seeders: parseInt($row.find('td').eq(2).text(), 10) or 0
                    leechers: parseInt($row.find('td').eq(3).text(), 10) or 0
                    timestamp: new Date()

            callback null, result


addresses = for index in [0...20]
    "http://thepiratebay.se/browse/#{program.number}/#{index}/3"


torrents = []

async.map addresses, processPage, (err, results) ->

    for torrentList in results
        for torrent in torrentList
            torrents.push torrent

    # filter fakes
    torrents = _.reject torrents, (item) ->
        item.seeders is 32310

    torrents = _.sortBy(torrents, 'leechers').reverse()
    torrents = _.first(torrents, 50)

    db = mongojs 'pirate_db'
    collection = db.collection program.collection
    
    collection.drop()

    for torrent in torrents
        collection.insert(torrent);

    db.close()

    console.log "fetched data at #{new Date()}"



