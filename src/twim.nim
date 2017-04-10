
import jsbind
import jswrapper
import xmlhttprequest
import mutationobserver
import chromewrapper
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
  let xhr = newXMLHTTPRequest()
  xhr.open("GET", imgsrc, true)
  xhr.responseType = "blob"
  xhr.addEventListener("load") do ():
    let arr = newArray[JSObj](1)
    arr[0] = xhr.response
    let file = newBlob(arr, nil)
    let link = document.createElement("a")
    link.href = window.URL.createObjectURL(file)
    link.setAttribute("download", elem.getAccountName() & "_" & imgsrc.splitPath().tail)
    let event = document.createEvent("MouseEvents")
    event.initEvent("click", false, true)
    link.dispatchEvent(event)
  xhr.send()

var isEnabled = false
var prevhref = location.href
var prevlen = 0
proc startTwim*() =
  console.log(location.href)
  # detect profile heading change
  if prevhref != location.href:
    prevlen = 0
    prevhref = location.href
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

chrome.extension.onMessage.addListener() do (request: jsstring, sender: JSObj, sendResponse: JSObj):
  if request == "enableTwim":
    isEnabled = true
  elif request == "disableTwim":
    isEnabled = false

startTwim()
let observer = newMutationObserver() do ():
  startTwim()
let observeropt = jsonParse("{\"attributes\": true, \"childList\": true, \"characterData\": true}")
observer.observe(document.getElementById("page-container"), observeropt)
