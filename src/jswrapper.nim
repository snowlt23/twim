
import jsbind
import jswrapper_macro

type
  JSArray*[T] = ref object of JSObj
  Element* = ref object of JSObj
  Style* = ref object of JSObj
  Event* = ref object of JSObj
  Window* = ref object of JSObj
  Document* = ref object of JSObj
  Console* = ref object of JSObj
  Location* = ref object of JSObj

when defined(js):
  type jsstring = cstring
elif defined(emscripten):
  type jsstring = string

defineJsGlobal window, Window
defineJsGlobal document, Document
defineJsGlobal console, Console
defineJsGlobal location, Location

# JSArray
proc `[]`*(jsarr: JSArray[Element], index: int): Element =
  return emTypeToNimType[Element](EM_ASM_INT("return _nimem_w(_nimem_o[$0][$1]);", jsarr.p, index))
proc test*(a, b: int): int =
  return emTypeToNimType[int](EM_ASM_INT("console.log($0); console.log($1); return $0 + $1;", toEmPtr(a), toEmPtr(b)))
# proc `[]=`*[T](jsarr: JSArray[T], index: int, val: T) {.jsaccessor.}
# proc `[]`*(jsarr: JSArray[Element], index: int): Element {.jsaccessor.}
# proc `[]=`*(jsarr: JSArray[Element], index: int, val: Element) {.jsaccessor.}
# proc `[]`*(jsarr: JSArray[Element], index: int): Element {.jsimportgWithName: "function() {console.log($0); return $0[$1];}".}
# proc `[]=`*(jsarr: JSArray[Element], index: int, val: Element) {.jsimportgWithName: "function() {return $0[$1] = $2;}".}
# proc length*[T](jsarr: JSArray[T]): int {.jsimportProp.}
# converter toSeq*[T](jsarr: JSArray[T]): seq[T] =
#   result = newSeq[T](jsarr.length)
#   for i in 0..<jsarr.length:
#     result[i] = jsarr[i]

# Document
proc getElementById*(document: Document, name: jsstring): Element {.jsimport.}
proc getElementsByClassName*(document: Document, name: jsstring): JSArray[Element] {.jsimport.}
proc getElementsByTagName*(document: Document, name: jsstring): JSArray[Element] {.jsimport.}

# Element
proc removeChild*(elem: Element, child: Element) {.jsimport.}
proc innerHTML*(elem: Element): jsstring {.jsimportProp.}
proc innerText*(elem: Element): jsstring {.jsimportProp.}
proc childNodes*(elem: Element): JsArray[Element] {.jsimportProp.}
proc parentNode*(elem: Element): Element {.jsimportProp.}
proc style*(elem: Element): Style {.jsimportProp.}
proc addEventListener*(elem: Element, eventname: jsstring, callback: proc (e: Event)) {.jsimport.}

# Style
# proc `[]`*(style: Style, key: jsstring): jsstring {.jsaccessor.}
# proc `[]=`*(style: Style, key: jsstring, value: jsstring) {.jsaccessor.}

# Console
proc log*(console: Console, obj: JSObj) {.jsimport.}
proc log*(console: Console, s: jsstring) {.jsimport.}

# # Location
# proc search*(loc: Location): jsstring {.jsimportProp.}

# # Global
# proc jsalert*(s: jsstring) {.jsimportg.}
# proc decodeURIComponent*(s: jsstring): jsstring {.jsimportg.}
