
import jsbind
import ../jswrapper/basics
import jswrapper_macro

type
  LocalStorage* = ref object of RootObj

defineJSGlobal localStorage, LocalStorage

proc setItem*(ls: LocalStorage, key: jsstring, val: JSObj) {.jsimport.}
proc getItem*(ls: LocalStorage, key: jsstring): JSObj {.jsimport.}
proc setStringItem*(ls: LocalStorage, key: jsstring, val: jsstring) {.jsimportWithName: "setItem".}
proc getStringItem*(ls: LocalStorage, key: jsstring): jsstring {.jsimportWithName: "getItem".}
