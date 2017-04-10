
import jsbind
import jswrapper_macro
export JSObj

type
  JSArray*[T] = ref object of JSObj
  Element* = ref object of JSObj
  Style* = ref object of JSObj
  Event* = ref object of JSObj
  Window* = ref object of JSObj
  URLObj* = ref object of JSObj
  Document* = ref object of JSObj
  Console* = ref object of JSObj
  Location* = ref object of JSObj
  Blob* = ref object of JSObj

when defined(js):
  type jsstring* = cstring
elif defined(emscripten):
  type jsstring* = string

defineJsGlobal window, Window
defineJsGlobal document, Document
defineJsGlobal console, Console
defineJsGlobal location, Location

# JSArray
proc newArray*[T](len: int): JSArray[T] {.jsimportgWithName: "new Array".}
proc `[]`*[T](jsarr: JSArray[T], index: int): T {.jsaccessor.}
proc `[]=`*[T](jsarr: JSArray[T], index: int, val: T) {.jsaccessor.}
proc length*[T](jsarr: JSArray[T]): int {.jsimportProp.}
converter toSeq*[T](jsarr: JSArray[T]): seq[T] =
  result = newSeq[T](jsarr.length)
  for i in 0..<jsarr.length:
    result[i] = jsarr[i]

# Document
proc createElement*(document: Document, name: jsstring): Element {.jsimport.}
proc getElementById*(document: Document, name: jsstring): Element {.jsimport.}
proc getElementsByClassName*(document: Document, name: jsstring): JSArray[Element] {.jsimport.}
proc getElementsByTagName*(document: Document, name: jsstring): JSArray[Element] {.jsimport.}
proc createEvent*(document: Document, name: jsstring): Event {.jsimport.}

# Element
proc removeChild*(elem: Element, child: Element) {.jsimport.}
proc innerHTML*(elem: Element): jsstring {.jsimportProp.}
proc innerText*(elem: Element): jsstring {.jsimportProp.}
proc childNodes*(elem: Element): JsArray[Element] {.jsimportProp.}
proc parentNode*(elem: Element): Element {.jsimportProp.}
proc addEventListener*(elem: Element, eventname: jsstring, callback: proc (e: Event)) {.jsimport.}
proc removeEventListener*(elem: Element, eventname: jsstring, callback: proc (e: Event), b: bool) {.jsimport.}
proc dispatchEvent*(elem: Element, event: Event) {.jsimport.}
proc style*(elem: Element): Style {.jsimportProp.}
proc setAttribute*(elem: Element, name: jsstring, value: jsstring) {.jsimport.}
template defineElementAttr*(name, V) =
  proc name*(elem: Element): V {.jsimportProp.}
  proc `name=`*(elem: Element, value: V) {.jsimportProp.}
defineElementAttr src, jsstring
defineElementAttr href, jsstring

# Style
template defineStyleAttr*(name) =
  proc name*(style: Style): jsstring {.jsimportProp.}
  proc `name=`*(style: Style, value: jsstring) {.jsimportProp.}
defineStyleAttr backgroundColor
defineStyleAttr opacity
defineStyleAttr display

proc `[]`*(style: Style, key: jsstring): jsstring {.jsaccessor.} # FIXME:
proc `[]=`*(style: Style, key: jsstring, value: jsstring) {.jsaccessor.} # FIXME:

# Event
proc initEvent*(event: Event, t: jsstring, b1, b2: bool) {.jsimport.}
proc currentTarget*(event: Event): Element {.jsimportProp.}

# Window
proc URL*(window: Window): URLObj {.jsimportProp.}

# URLObj
proc createObjectURL*(url: URLObj, blob: Blob): jsstring {.jsimport.}

# Console
proc log*(console: Console, obj: JSObj) {.jsimport.}
proc log*(console: Console, s: jsstring) {.jsimport.}

# # Location
# proc search*(loc: Location): jsstring {.jsimportProp.}

# # Global
# proc jsalert*(s: jsstring) {.jsimportg.}
# proc decodeURIComponent*(s: jsstring): jsstring {.jsimportg.}

# Blob
proc newBlob*(data: JSObj, opt: JSObj): Blob {.jsimportgWithName: "new Blob".}
