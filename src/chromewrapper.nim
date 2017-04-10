
import jsbind
import jswrapper
import jswrapper_macro

type
  Chrome* = ref object of JSObj
  Extension* = ref object of JSObj
  BrowserAction* = ref object of JSObj
  PageAction* = ref object of JSObj
  OnMessage* = ref object of JSObj
  OnClicked* = ref object of JSObj
  Tab* = ref object of JSObj
  TabID* = ref object of JSObj
  Tabs* = ref object of JSObj

defineJsGlobal chrome, Chrome

# Chrome
proc extension*(chrome: Chrome): Extension {.jsimportProp.}
proc browserAction*(chrome: Chrome): BrowserAction {.jsimportProp.}
proc pageAction*(chrome: Chrome): PageAction {.jsimportProp.}
proc tabs*(chrome: Chrome): Tabs {.jsimportProp.}

# Extension
proc onMessage*(ex: Extension): OnMessage {.jsimportProp.}

# BrowserAction
proc onClicked*(ba: BrowserAction): OnClicked {.jsimportProp.}

# PageAction

# OnMessage
proc addListener*(om: OnMessage, callback: proc (request: jsstring, sender: JSObj ,sendResponse: JSObj)) {.jsimport.}
# OnClicked
proc addListener*(oc: OnClicked, callback: proc (tab: Tab)) {.jsimport.}

# Tab
proc id*(tab: Tab): TabID {.jsimportProp.}
# Tabs
proc executeScript*(tabs: Tabs, tabid: TabID, opt: JSObj, callback: proc ()) {.jsimport.}
proc sendMessage*(tabs: Tabs, tabid: TabID, msg: jsstring) {.jsimport.}
