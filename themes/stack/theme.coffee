messageQueue = []

document.addEventListener 'message', (data) ->
    messageQueue.push data.detail # CustomEvents use the .detail field

paddedTime = (str) -> if str.length < 2 then '0' + str else str

maxMessages = 5
appendMessage = (data) ->
    if document.querySelectorAll('.messages > li:not(.hidden)').length == maxMessages
        hideMsg = document.querySelector('.messages > li:not(.hidden)')
        hideMsg.className += ' hidden'
        hideMsg.addEventListener 'webkitAnimationEnd', () ->
            hideMsg.parentNode.removeChild hideMsg

    now = new Date
    h = paddedTime now.getHours().toString()
    m = paddedTime now.getMinutes().toString()
    time = h + ':' + m
    template = """
        #{if data.badges then "<div class=\"badges\">#{data.badges}</div>" else ""}
        <div class="name">
            #{data.user.username}
        </div>
        <div class="time">#{time}</div>
        <div class="msg">#{data.message}</div>
    """

    $row = document.createElement 'li'
    $row.style.borderColor = data.user.color
    $row.innerHTML = template

    $messages = document.querySelector '.messages'
    $messages.appendChild $row

    $messages.style.bottom = '-' + ($row.offsetHeight + 1) + 'px'

    setTimeout ->
        $messages.className += ' animated'
        $messages.style.bottom = 0

    setTimeout ->
        $messages.className = $messages.className.replace ' animated', ''
    , 900


messageLoop = -> appendMessage messageQueue.shift() if messageQueue.length > 0

setInterval messageLoop, 1000
