https = require 'https'
NodeCache = require 'node-cache'

emoteCache = new NodeCache()

getData = (url, cb) -> # dont need this to be parsed as thats on client side
    https.get(url, (res) ->
        body = ''
        res.on('data', (d) -> body += d)
        res.on('end', (d) -> cb body)
    )

checkCacheElseGet = (res, url) ->
    emoteCache.get(url, (err, val) ->
        if err or val is undefined
            # populate cache, 15 min cache
            getData(url, (data) ->
                emoteCache.set url, data, 15*60
                res.write data
                res.end()
            )
        else
            res.write val
            res.end()
    )

module.exports = (url) ->
    return (req, res) ->
        checkCacheElseGet res, url