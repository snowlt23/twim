
import jsbind
import ../jswrapper/basics
import jswrapper_macro
import json
export json

type
  Chrome* = ref object of JSObj

type
  Extension* = ref object of JSObj
  BrowserAction* = ref object of JSObj
  PageAction* = ref object of JSObj
  Storage* = ref object of JSObj
  Downloads* = ref object of JSObj
  Runtime* = ref object of JSObj

type
  OnMessage* = ref object of JSObj
  OnClicked* = ref object of JSObj

type
  Tab* = ref object of JSObj
  TabID* = ref object of JSObj
  Tabs* = ref object of JSObj

defineJSGlobal chrome, Chrome

# Chrome
proc extension*(chrome: Chrome): Extension {.jsimportProp.}
proc browserAction*(chrome: Chrome): BrowserAction {.jsimportProp.}
proc pageAction*(chrome: Chrome): PageAction {.jsimportProp.}
proc tabs*(chrome: Chrome): Tabs {.jsimportProp.}
proc downloads*(chrome: Chrome): Downloads {.jsimportProp.}
proc runtime*(chrome: Chrome): Runtime {.jsimportProp.}

# Extension
proc onMessage*(ex: Extension): OnMessage {.jsimportProp.}

# BrowserAction
proc onClicked*(ba: BrowserAction): OnClicked {.jsimportProp.}

# PageAction

# Storage

# Downloads
proc download*(downloads: Downloads, opt: JSObj) {.jsimport.}

# Runtime
proc sendMessage*(runtime: Runtime, msg: JSObj, callback: proc () = proc () = discard) {.jsimport.}
proc onMessage*(runtime: Runtime): OnMessage {.jsimportProp.}

# OnMessage
proc addListener*(om: OnMessage, callback: proc (request: jsstring, sender: JSObj ,sendResponse: JSObj)) {.jsimport.}
# OnClicked
proc addListener*(oc: OnClicked, callback: proc (tab: Tab)) {.jsimport.}

# Tab
proc id*(tab: Tab): TabID {.jsimportProp.}
# Tabs
proc executeScript*(tabs: Tabs, tabid: TabID, opt: JSObj, callback: proc ()) {.jsimport.}
proc sendMessage*(tabs: Tabs, tabid: TabID, msg: jsstring) {.jsimport.}

template jsonobj*(obj: untyped): JSObj = jsonParse($(%* obj))
