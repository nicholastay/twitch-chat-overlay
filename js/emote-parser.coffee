customEmotes = []

window.emoteParse = (user, msg) ->
    return msg if customEmotes.length < 1 and not window.chatConfig.emotes.twitch
    replaceEmotes msg.split(' '), if window.chatConfig.emotes.twitch then getMsgTwitchEmotes(user, msg) else []

emoteLoad = ->
    if window.chatConfig.emotes.bttv
        fetchEmotes 'https://api.betterttv.net/2/emotes', parseBTTVEmotes
        fetchEmotes 'https://api.betterttv.net/2/channels/' + window.chatConfig.username, parseBTTVEmotes

fetchEmotes = (url, callback) ->
    fetch(url)
        .then (response) -> return response.json()
        .then (emoteData) ->
            # great error handling
            try
                callback(emoteData)
            catch nothing

# concat this to the other ones
getMsgTwitchEmotes = (user, message) ->
    return [] if not user.emotes
    emotes = []
    Object.keys(user.emotes).forEach (emoteId) ->
        i = user.emotes[emoteId][0].split('-')
        emotes.push code: message.substr(Number(i[0]), Number(i[1])+1), url: 'https://static-cdn.jtvnw.net/emoticons/v1/' + emoteId + '/1.0'
    return emotes

parseBTTVEmotes = (data) ->
    data.emotes.forEach (emote) ->
        customEmotes.push code: emote.code, url: parseBTTVURL(data.urlTemplate, emote) 

parseBTTVURL = (tpl, emote) ->
    tpl
        .replace /{{id}}/, emote.id
        .replace /{{image}}/, '1x'

# http://stackoverflow.com/questions/3446170/escape-string-for-use-in-javascript-regex
escapeRegExp = (str) -> str.replace /[-\/\\^$*+?.()|[\]{}]/g, '\\$&'

reducer = (previous, current) ->
    previous.replace new RegExp('^' + escapeRegExp(current.code) + '$', 'g'), '<img src="' + current.url + '">'

replaceEmotes = (words, msgEmotes) ->
    replacedWords = words.map (word) -> customEmotes.concat(msgEmotes).reduce reducer, word
    replacedWords.join ' '

emoteLoad()