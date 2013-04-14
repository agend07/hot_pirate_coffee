async = require 'async'
request = require 'request'
cheerio = require 'cheerio'
_ = require 'underscore'
fs = require 'fs'
mongojs = require 'mongojs'


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
    "http://thepiratebay.se/browse/201/#{index}/3"

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

    # write to file
    # fs.writeFile('data.json', JSON.stringify(torrents, null, 4))

    # write to console
    # for torrent in torrents
    #     console.log torrent

    # write do mongodb
    db = mongojs 'mongodb://localhost/pirate_db', ['movies']
    db.movies.drop()

    for torrent in torrents
        db.movies.insert(torrent);

    db.close()



