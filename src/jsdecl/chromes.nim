
import jsbind
import ../jsdecl/basics
import jsdecl_macros

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
proc sendMessage*(ex: Extension, tabid: TabID, msg: JSObj, callback: proc (response: JSObj) = nil) {.jsimport.}
proc sendMessage*(ex: Extension, tabid: TabID, msg: jsstring, callback: proc (response: JSObj) = nil) {.jsimport.}

# BrowserAction
proc onClicked*(ba: BrowserAction): OnClicked {.jsimportProp.}
proc setIcon*(ba: BrowserAction, opt: JSObj) {.jsimport.}

# PageAction

# Storage

# Downloads
proc download*(downloads: Downloads, opt: JSObj) {.jsimport.}

# Runtime
proc sendMessage*(runtime: Runtime, msg: JSObj, callback: proc () = proc () = discard) {.jsimport.}
proc onMessage*(runtime: Runtime): OnMessage {.jsimportProp.}

# OnMessage
proc addListener*(om: OnMessage, callback: proc (request: JSObj, sender: JSObj ,sendResponse: JSObj)) {.jsimport.}
# OnClicked
proc addListener*(oc: OnClicked, callback: proc (tab: Tab)) {.jsimport.}

# Tab
proc id*(tab: Tab): TabID {.jsimportProp.}
# Tabs
proc query*(tabs: Tabs, queryinfo: JSObj, callback: proc (tabs: JSArray[Tab])) {.jsimport.}
proc executeScript*(tabs: Tabs, tabid: TabID, opt: JSObj, callback: proc ()) {.jsimport.}
proc sendMessage*(tabs: Tabs, tabid: TabID, msg: JSObj) {.jsimport.}
proc sendMessage*(tabs: Tabs, tabid: TabID, msg: jsstring) {.jsimport.}
