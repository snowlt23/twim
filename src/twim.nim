
import jswrapper
import xmlhttprequest

let imgelems = document.getElementsByClassName("js-adaptive-photo").toSeq()
console.log(imgelems[0])

proc addOverlayFilter*(elem: Element) =
  elem.style.backgroundColor = "blue"
  elem.childNodes[1].style.opacity = "0.6"
  elem.childNodes[1].style.display = "block"
proc removeOverlayFilter*(elem: Element) =
  elem.style.backgroundColor = "none"
  elem.childNodes[1].style.opacity = "1.0"

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
    link.setAttribute("download", "test.jpg")
    let event = document.createEvent("MouseEvents")
    event.initEvent("click", false, true)
    link.dispatchEvent(event)
  xhr.send()

for imgelem in imgelems:
  imgelem.addEventListener("mouseover") do (e: Event):
    console.log(e.currentTarget)
    e.currentTarget.addOverlayFilter()
  imgelem.addEventListener("mouseout") do (e: Event):
    e.currentTarget.removeOverlayFilter()
  imgelem.addEventListener("click") do (e: Event):
    e.currentTarget.downloadImage()
