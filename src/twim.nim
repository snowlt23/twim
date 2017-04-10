
import jswrapper

let imgelems = document.getElementsByClassName("js-adaptive-photo").toSeq()
# console.log(imgelems[0])

proc addOverlayFilter*(elem: Element) =
  elem.parentNode.style["background-color"] = "blue"
  elem.style["opacity"] = "0.6"
  elem.style["display"] = "block"
proc removeOverlayFilter*(elem: Element) =
  elem.parentNode.style["background-color"] = "none"
  elem.style["opacity"] = "1.0"

for imgelem in imgelems:
  imgelem.addEventListener("mouseover") do (e: Event):
    console.log(imgelem)
    imgelem.addOverlayFilter()
  imgelem.addEventListener("mouseout") do (e: Event):
    imgelem.removeOverlayFilter()
