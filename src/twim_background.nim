
import jswrapper
import chromewrapper

var switchFlag = false

chrome.browserAction.onClicked.addListener() do (tab: Tab):
  if not switchFlag:
    chrome.tabs.executeScript(nil, jsonParse("{file: \"twim-start-loader.js\"}")) do ():
      chrome.tabs.executeScript(nil, jsonParse("file: \"twim-start.js\"")) do ():
        discard
    switchFlag = true
  else:
    chrome.tabs.executeScript(nil, jsonParse("{file: \"twim-end-loader.js\"}")) do ():
      chrome.tabs.executeScript(nil, jsonParse("file: \"twim-end.js\"")) do ():
        discard
    switchFlag = false

