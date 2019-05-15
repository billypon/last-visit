lastTabs = null

getRecentlyClosed = ->
  new Promise (resolve) ->
    chrome.sessions.getRecentlyClosed (sessions) ->
      tabs = null
      appendTab = ({ id, title, url, favIconUrl }) ->
        if /^https?:\/\//.test url
          tabs = tabs or [ ]
          tabs.push { title, url, favIconUrl }
      sessions.forEach ({ window, tab }) ->
        window.tabs.forEach appendTab if window
        appendTab tab if tab
      resolve tabs

getLastTabs = ->
  lastTabs = await getRecentlyClosed() while not lastTabs
  lastTabs.filter ({ canceled }) -> not canceled

chrome.browserAction.onClicked.addListener ->
  chrome.tabs.create
    url: 'last-visit.html'
    selected: true
