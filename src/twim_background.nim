
import jsdecl.basics
import jsdecl.chromes
import jsdecl.localstorages
import boost.richstring

import twim_types

var switchFlag = false

proc enableTwim*(tab: Tab) =
  chrome.tabs.sendMessage(tab.id, "enableTwim")
  chrome.browserAction.setIcon(jsonParse("""{"path": "icon-enable.png"}"""))
proc disableTwim*(tab: Tab) =
  chrome.tabs.sendMessage(tab.id, "disableTwim")
  chrome.browserAction.setIcon(jsonParse("""{"path": "icon-disable.png"}"""))

chrome.runtime.onMessage.addListener() do (request, sender, sendResponse: JSObj):
  let msg = jscast[DownloadMessage](request)
  if $msg.messagetype == "download":
    var savedirectory = $localStorage.getStringItem("save-directory")
    if savedirectory == nil:
      savedirectory = ""
    if savedirectory != "":
      savedirectory  &= "/"
    chrome.downloads.download(jsonParse(fmt"""{"url": "${msg.url}", "filename": "${savedirectory & msg.filename}"}"""))

chrome.browserAction.onClicked.addListener() do (tab: Tab):
  if not switchFlag:
    enableTwim(tab)
    switchFlag = true
  else:
    disableTwim(tab)
    switchFlag = false
