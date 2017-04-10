
import jswrapper

console.log("Hello, World")
console.log($test(1, 2))

let imgelems = document.getElementsByClassName("js-adaptive-photo")
# console.log(imgelems)
console.log(imgelems[0])

# proc addOverlayFilter*(elem: Element) =
#   elem.parentNode.style["background-color"] = "blue"
#   elem.style["opacity"] = "0.6"
#   elem.style["display"] = "block"
# proc removeOverlayFilter*(elem: Element) =
#   elem.parentNode.style["background-color"] = "none"
#   elem.style["opacity"] = "1.0"

# for imgelem in imgelems:
#   console.log(imgelem)
#   imgelem.addEventListener("mouseenter") do (e: Event):
#     imgelem.addOverlayFilter()
#   imgelem.addEventListener("mouseout") do (e: Event):
#     imgelem.removeOverlayFilter()
