getQueryVariables = () ->
    queries = window.location.search.substring(1).split '&'
    out = {}
    for q in queries
        pair = q.split('=')
        out[decodeURIComponent(pair[0])] = decodeURIComponent(pair[1])
    out

window.chatConfig =
    _query: _query = getQueryVariables()
    username: _query.username
    twitchid: null
    notify:
        chat: (_query.chat == 'true') || true
        subs: (_query.subs == 'true') || false
        subanniversary: (_query.subannv == 'true') || false
        hosts: (_query.hosts == 'true') || false
    maxmessages: Number(_query.maxmsgs) || 5
    emotes:
        twitch: if (_query.twitchemotes == 'false') is true then false else true
        bttv: (_query.bttvemotes == 'true') || false
        ffz: (_query.ffzemotes == 'true') || false

window.fetchJson = (url, callback) ->
    fetch(url)
        .then (response) -> return response.json()
        .then (emoteData) ->
            # great error handling
            try
                callback(emoteData)
            catch nothing

client = new tmi.client
    options:
        debug: true
    connection:
        reconnect: true
        secure: if location.protocol is 'https:' then true else false
    channels: ['#' + window.chatConfig.username]

client.connect()

# input sanitizer
escapeHtml = (str) ->
    div = document.createElement 'div'
    div.appendChild document.createTextNode(str)
    return div.innerHTML

getDisplayName = (user) ->
    return user.username if not user['display-name']
    return user['display-name'] if user.username == user['display-name'].toLowerCase()
    return "#{user['display-name']} (#{user.username})"

systemMessage = (str) ->
    event = new CustomEvent('message', {'detail': {user: {color: '#f946a7'}, displayName: 'Chat Overlay', badges: "<img src=\"/cog.png\" class=\"badge badge-system\">", message: str, action: false}});
    document.dispatchEvent(event);

client.addListener 'chat', (channel, user, message) ->
    if window.chatConfig.notify.chat
        event = new CustomEvent('message', {'detail': {user: user, displayName: getDisplayName(user), badges: window.parseBadges(user), message: window.emoteParse(user, escapeHtml(message)), action: false}});
        document.dispatchEvent(event);

client.addListener 'action', (channel, user, message) ->
    if window.chatConfig.notify.chat
        event = new CustomEvent('message', {'detail': {user: user, displayName: getDisplayName(user), badges: window.parseBadges(user), message: window.emoteParse(user, escapeHtml(message)), action: true}});
        document.dispatchEvent(event);

client.addListener 'subscription', (channel, user) ->
    if window.chatConfig.notify.subs
        event = new CustomEvent('sub', {'detail': {user: user}});
        document.dispatchEvent(event);

client.addListener 'subanniversary', (channel, user, months) ->
    if window.chatConfig.notify.subanniversary
        event = new CustomEvent('subanniversary', {'detail': {user: user, months: months}});
        document.dispatchEvent(event);

client.addListener 'hosted', (channel, user, viewers) ->
    if window.chatConfig.notify.hosts
        event = new CustomEvent('host', {'detail': {user: user, viewers: viewers}});
        document.dispatchEvent(event);

client.addListener 'connected', (address, port) ->
    systemMessage 'Connected to twitch.tv servers!'

client.addListener 'disconnected', (reason) ->
    systemMessage 'You have been disconnected from twitch.tv. (Reason: ' + reason + ').'

client.addListener 'roomstate', (channel, state) ->
    window.chatConfig.twitchid = state['room-id']
    systemMessage 'Joined your channel chatroom (' + channel + ').'
    document.dispatchEvent new CustomEvent('ready')
