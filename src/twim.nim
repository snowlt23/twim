
import jswrapper.basics
import jswrapper.xmlhttprequest
import jswrapper.mutationobserver
import jswrapper.chromes
import strutils, boost.richstring
import os

proc addOverlayFilter*(elem: Element) =
  elem.style.backgroundColor = "blue"
  elem.childNodes[1].style.opacity = "0.6"
  elem.childNodes[1].style.display = "block"
proc removeOverlayFilter*(elem: Element) =
  elem.style.backgroundColor = "none"
  elem.childNodes[1].style.opacity = "1.0"

proc getAccountName*(elem: Element): string =
  let contentelem = case elem.parentNode.className
                    of "AdaptiveMedia-threeQuartersWidthPhoto", "AdaptiveMedia-twoThirdsWidthPhoto", "AdaptiveMedia-halfWidthPhoto":
                      elem.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode
                    of "AdaptiveMedia-thirdHeightPhoto", "AdaptiveMedia-halfHeightPhoto":
                      elem.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode
                    else:
                      elem.parentNode.parentNode.parentNode.parentNode.parentNode
  return contentelem.childNodes[1].childNodes[1].childNodes[4].childNodes[1].innerText

proc downloadImage*(elem: Element) =
  let imgsrc = elem.childNodes[1].src
  let filename = elem.getAccountName() & "_" & imgsrc.splitPath().tail
  chrome.runtime.sendMessage(jsonobj({
    "type": "download",
    "url": imgsrc, 
    "filename": filename,
  }))

var isEnabled = false
var prevlen = 0
proc registerTwimEvent*() =
  let imgelems = document.getElementsByClassName("js-adaptive-photo").toSeq()
  for i in prevlen..<imgelems.len:
    let imgelem = imgelems[i]
    imgelem.addEventListener("mouseover") do (e: Event):
      if isEnabled:
        e.currentTarget.addOverlayFilter()
    imgelem.addEventListener("mouseout") do (e: Event):
      if isEnabled:
        e.currentTarget.removeOverlayFilter()
    imgelem.addEventListener("click") do (e: Event):
      if isEnabled:
        e.currentTarget.downloadImage()
        e.stopPropagation()
  prevlen = imgelems.len

proc startTwim*() =
  registerTwimEvent()
  let imgobserver = newMutationObserver() do ():
    registerTwimEvent()
  let imgobserveropt = jsonParse("{\"attributes\": true, \"childList\": true}")
  imgobserver.observe(document.getElementById("stream-items-id"), imgobserveropt)

chrome.extension.onMessage.addListener() do (request: jsstring, sender: JSObj, sendResponse: JSObj):
  if request == "enableTwim":
    isEnabled = true
  elif request == "disableTwim":
    isEnabled = false

startTwim()

let pageobserver = newMutationObserver() do ():
  console.log("changed page!")
  prevlen = 0
  startTwim()
let pageobserveropt = jsonParse("{\"attributes\": true, \"childList\": true}")
pageobserver.observe(document.getElementById("page-container"), pageobserveropt)

