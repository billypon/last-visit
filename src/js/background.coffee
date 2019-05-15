lastTabs = JSON.parse localStorage.tabs or '[]'
currentTabs = { }

saveTab = ({ id, title, url, favIconUrl }) ->
  currentTabs[id] = { title, url, favIconUrl } if /^https?:\/\//.test url

removeTab = (id) ->
  delete currentTabs[id]

saveTabs = ->
  _lastTabs = lastTabs.filter ({ canceled }) -> not canceled
  _currentTabs = Object.values currentTabs
  localStorage.tabs = JSON.stringify _lastTabs.concat _currentTabs
  _lastTabs

syncTimeout = 0
do syncTabs = ->
  currentTabs = { }
  chrome.windows.getAll populate: true, (windows) ->
    windows.forEach ({ tabs }) ->
      tabs.forEach saveTab
    saveTabs()
    clearTimeout syncTimeout
    syncTimeout = setTimeout syncTabs, 60000

chrome.browserAction.onClicked.addListener ->
  tabs = saveTabs()
  if tabs.length
    chrome.tabs.create
      url: 'last-visit.html'
      selected: true

chrome.tabs.onCreated.addListener saveTab

chrome.tabs.onUpdated.addListener (id, info, tab) -> saveTab tab

chrome.tabs.onRemoved.addListener (id) -> removeTab id

chrome.tabs.onReplaced.addListener (_, id) -> removeTab id

chrome.windows.onRemoved.addListener saveTabs
