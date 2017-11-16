messageQueue = []

document.addEventListener 'message', (data) ->
    appendMessage data.detail # CustomEvents use the .detail field

paddedTime = (str) -> if str.length < 2 then '0' + str else str

appendMessage = (data) ->
    # It is a ticker, remove old messages
    oldMessages = document.querySelector(".message")
    if oldMessages
        oldMessages.parentNode.removeChild(oldMessages)

    # Time stuff from dark theme
    now = new Date
    h = paddedTime now.getHours().toString()
    m = paddedTime now.getMinutes().toString()
    time = h + ':' + m

    template = """
        #{if data.badges then "<span class=\"badges\">#{data.badges}</span>" else ""}
        <span class="time">#{time}</span>
        <span class="user" style="color: #{data.user.color};">#{data.displayName}</span>:
        <span class="msg">#{data.message}</span>
    """

    $row = document.createElement 'div'
    $row.className = 'message'
    $row.innerHTML = template

    $row.addEventListener 'webkitAnimationEnd', () ->
        $row.parentNode.removeChild $row

    document.querySelector('.messages').appendChild $row
