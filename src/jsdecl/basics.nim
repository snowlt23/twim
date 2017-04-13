
import jsbind
export jsstring
export JSObj

import jsdecl_macros
export jscast

import json
export json

import strutils

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

defineJSGlobal window, Window
defineJSGlobal document, Document
defineJSGlobal console, Console
defineJSGlobal location, Location

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
proc childNodes*(elem: Element): JsArray[Element] {.jsimportProp.}
proc parentNode*(elem: Element): Element {.jsimportProp.}
proc className*(elem: Element): jsstring {.jsimportProp.}
proc classList*(elem: Element): JSArray[jsstring] {.jsimportProp.}
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
defineElementAttr value, jsstring
defineElementAttr innerText, jsstring
defineElementAttr innerHTML, jsstring

# Style
template defineStyleAttr*(name) =
  proc name*(style: Style): jsstring {.jsimportProp.}
  proc `name=`*(style: Style, value: jsstring) {.jsimportProp.}
defineStyleAttr color
defineStyleAttr backgroundColor
defineStyleAttr opacity
defineStyleAttr display

proc `[]`*(style: Style, key: jsstring): jsstring {.jsaccessor.} # FIXME:
proc `[]=`*(style: Style, key: jsstring, value: jsstring) {.jsaccessor.} # FIXME:

# Event
proc initEvent*(event: Event, t: jsstring, b1, b2: bool) {.jsimport.}
proc currentTarget*(event: Event): Element {.jsimportProp.}
proc stopPropagation*(event: Event) {.jsimport.}

# Window
proc addEventListener*(window: Window, eventname: jsstring, callback: proc (e: Event)) {.jsimport.}
proc URL*(window: Window): URLObj {.jsimportProp.}

# URLObj
proc createObjectURL*(url: URLObj, blob: Blob): jsstring {.jsimport.}

# Console
proc log*(console: Console, obj: JSObj) {.jsimport.}
proc log*(console: Console, s: jsstring) {.jsimport.}

# Location
proc href*(loc: Location): jsstring {.jsimportProp.}
proc search*(loc: Location): jsstring {.jsimportProp.}

# Global
proc jsalert*(s: jsstring) {.jsimportgWithName: "alert".}
proc decodeURIComponent*(s: jsstring): jsstring {.jsimportg.}
proc jsonParse*(s: jsstring): JSObj {.jsimportgWithName: "JSON.parse".}
proc jsonStringify*(obj: JSObj): jsstring {.jsimportgWithName: "JSON.stringify".}
proc setTimeout*(callback: proc (), ms: int) {.jsimportg.}
proc setTimeout*(ms: int, callback: proc ()) =
  setTimeout(callback, ms)

# Blob
proc newBlob*(data: JSObj, opt: JSObj): Blob {.jsimportgWithName: "new Blob".}

# json
converter toString*(jsstr: jsstring): string = $jsstr
converter toJSObj*(node: JsonNode): JSObj = jsonParse($node)
converter toJsonNode*(obj: JSObj): JsonNode = parseJson(jsonStringify(obj))
proc `$`*(obj: JSObj): string = ($toJsonNode(obj)).replace("\"")

when defined(js):
  template trycatch*(t: untyped, c: untyped): untyped =
    {.emit: "try {".}
    t
    {.emit: "} catch (e) {"}
    c
    {.emit: "}"}
