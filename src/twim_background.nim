
import jsdecl.basics
import jsdecl.chromes
import jsdecl.localstorages
import boost.richstring

import twim_types

var switchFlag = false

proc queryTwitterTabs*(callback: proc (tabs: seq[Tab])) =
  chrome.tabs.query(jsonParse("""{"url": "https://twitter.com/*"}""")) do (tabs: JSArray[Tab]):
    callback(tabs.toSeq())

proc enableTwim*(tab: Tab) =
  queryTwitterTabs() do (tabs: seq[Tab]):
    for tab in tabs:
      chrome.tabs.sendMessage(tab.id, "enableTwim")
  # chrome.tabs.sendMessage(tab.id, "enableTwim")
  chrome.browserAction.setIcon(jsonParse("""{"path": "icon-enable.png"}"""))
proc disableTwim*(tab: Tab) =
  queryTwitterTabs() do (tabs: seq[Tab]):
    for tab in tabs:
      chrome.tabs.sendMessage(tab.id, "disableTwim")
  # chrome.tabs.sendMessage(tab.id, "disableTwim")
  chrome.browserAction.setIcon(jsonParse("""{"path": "icon-disable.png"}"""))

chrome.runtime.onMessage.addListener() do (request, sender, sendResponse: JSObj):
  let msg = jscast[DownloadMessage](request)
  if $msg.messagetype == "download":
    let savedirectoryjs = localStorage.getStringItem("save-directory")
    var savedirectory = if savedirectoryjs != nil:
                           $savedirectoryjs
                         else:
                           ""
    if savedirectory == nil:
      savedirectory = ""
    if savedirectory != "":
      savedirectory  &= "/"
    chrome.downloads.download(jsonParse(fmt"""{"url": "${msg.url}", "filename": "${savedirectory & msg.filename}"}""")) do ():
      if chrome.runtime.lastError != nil:
        jsalert("画像がダウンロードできませんでした\nファイルの保存先が不正です")

chrome.browserAction.onClicked.addListener() do (tab: Tab):
  if not switchFlag:
    enableTwim(tab)
    switchFlag = true
  else:
    disableTwim(tab)
    switchFlag = false
