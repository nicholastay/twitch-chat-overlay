customEmotes = []

window.emoteParse = (user, msg) ->
    return msg if customEmotes.length < 1 and not window.chatConfig.emotes.twitch
    replaceEmotes msg.split(' '), if window.chatConfig.emotes.twitch then getMsgTwitchEmotes(user, msg) else []

emoteLoad = ->
    if window.chatConfig.emotes.bttv
        window.fetchJson 'https://api.betterttv.net/2/emotes', parseBTTVEmotes
        window.fetchJson 'https://api.betterttv.net/2/channels/' + window.chatConfig.username, parseBTTVEmotes
    if window.chatConfig.emotes.ffz
        window.fetchJson 'https://api.frankerfacez.com/v1/set/global', parseGlobalFFZEmotes
        window.fetchJson 'https://api.frankerfacez.com/v1/room/' + window.chatConfig.username, parseChannelFFZEmotes

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

parseGlobalFFZEmotes = (data) ->
    data.default_sets.forEach (setId) ->
        parseFFZEmoteSet data.sets[setId]

parseChannelFFZEmotes = (data) ->
    Object.keys(data.sets).forEach (setId) ->
        parseFFZEmoteSet data.sets[setId]

parseFFZEmoteSet = (set) ->
    set.emoticons.forEach (emote) ->
        customEmotes.push code: emote.name, url: emote.urls["1"]


# http://stackoverflow.com/questions/3446170/escape-string-for-use-in-javascript-regex
escapeRegExp = (str) -> str.replace /[-\/\\^$*+?.()|[\]{}]/g, '\\$&'

reducer = (previous, current) ->
    previous.replace new RegExp('^' + escapeRegExp(current.code) + '$', 'g'), '<img src="' + current.url + '">'

replaceEmotes = (words, msgEmotes) ->
    replacedWords = words.map (word) -> customEmotes.concat(msgEmotes).reduce reducer, word
    replacedWords.join ' '

document.addEventListener 'ready', (() -> emoteLoad()), once: true