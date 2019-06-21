do i18n = (element = document) ->
  element.childNodes.forEach (node) ->
    switch node.nodeType
      when 1 then i18n node
      when 3 then node.nodeValue = node.nodeValue.replace /__MSG_(\w+)__/g, (_, x) -> chrome.i18n.getMessage x

interval = setInterval ->
  return unless localStorage.tabs
  clearInterval interval

  lastTabs = JSON.parse localStorage.tabs
    .filter ({ canceled }) -> not canceled

  openTab = (tab) ->
    unless tab.canceled
      chrome.tabs.create
        url: tab.url
        selected: true

  toggleTab = (tab, item, cancel) ->
    tab.canceled = cancel or not tab.canceled
    item.classList.toggle 'selected', tab.canceled

  tabList = document.querySelector 'ul'
  lastTabs.slice(0).reverse().forEach (tab) ->
    { title, url, favIconUrl, canceled } = tab
    item = document.createElement 'li'
    item.innerHTML = """
      <div class="close">&times;</div>
      <div class="icon" style="background: url('#{favIconUrl}'), url('chrome://favicon/')"></div>
      <a href="#{url}" target="_blank">#{title}</a>
      <div class="url">#{url}</div>
    """
    item.querySelector('.close').addEventListener 'click', (event) -> toggleTab tab, item
    item.querySelector('a').addEventListener 'click', (event) -> toggleTab tab, item, true
    tabList.appendChild item
  tabItems = tabList.querySelectorAll 'li'

  document.querySelector('.open').addEventListener 'click', ->
    lastTabs.forEach (tab) ->
      openTab tab
      tab.canceled = true
    close()

  document.querySelector('.clear').addEventListener 'click', ->
    tabItems.forEach (item) ->
      unless item.classList.contains 'selected'
        item.querySelector('.close').click()
, 1000
