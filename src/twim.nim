
import jswrapper
import xmlhttprequest
import os

proc addOverlayFilter*(elem: Element) =
  elem.style.backgroundColor = "blue"
  elem.childNodes[1].style.opacity = "0.6"
  elem.childNodes[1].style.display = "block"
proc removeOverlayFilter*(elem: Element) =
  elem.style.backgroundColor = "none"
  elem.childNodes[1].style.opacity = "1.0"

proc getAccountName*(elem: Element): string =
  let contentelem = elem.parentNode.parentNode.parentNode.parentNode.parentNode
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

proc mouseoverCallback*(e: Event) =
  e.currentTarget.addOverlayFilter()
proc mouseoutCallback*(e: Event) =
  e.currentTarget.removeOverlayFilter()
proc clickCallback*(e: Event) =
  e.currentTarget.downloadImage()

proc startTwim*() =
  let imgelems = document.getElementsByClassName("js-adaptive-photo").toSeq()
  for imgelem in imgelems:
    imgelem.addEventListener("mouseover", mouseoverCallback)
    imgelem.addEventListener("mouseout", mouseoutCallback)
    imgelem.addEventListener("click", clickCallback)
proc endTwim*() =
  let imgelems = document.getElementsByClassName("js-adaptive-photo").toSeq()
  for imgelem in imgelems:
    imgelem.removeEventListener("mouseover", mouseoverCallback, false)
    imgelem.removeEventListener("mouseout", mouseoutCallback, false)
    imgelem.removeEventListener("click", clickCallback, false)

startTwim()
