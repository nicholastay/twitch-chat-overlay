badges = {}

window.parseBadges = (user) ->
    if not user.badges
        return null
    out = ""
    Object.keys(user.badges).forEach (badge) ->
        version = user.badges[badge]
        out += """
        <img src="#{badges[badge][version]}" class="badge badge-#{badge} badge-#{badge}-#{version}" alt="badge-#{badge}-#{version}">
        """
    return out

badgeLoad = ->
    window.fetchJson 'https://badges.twitch.tv/v1/badges/global/display?language=en', parseBadgeSets # Global
    window.fetchJson 'https://badges.twitch.tv/v1/badges/channels/' + window.chatConfig.twitchid + '/display?language=en', parseBadgeSets # Channel's

parseBadgeSets = (badgeSets) ->
    Object.keys(badgeSets.badge_sets).forEach (badge) ->
        badges[badge] = {}
        Object.keys(badgeSets.badge_sets[badge].versions).forEach (version) ->
            badges[badge][version] = badgeSets.badge_sets[badge].versions[version].image_url_1x

document.addEventListener 'ready', (() -> badgeLoad()), once: true
