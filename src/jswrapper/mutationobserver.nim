
import jsbind
import ../jswrapper/basics

type
  MutationObserver* = ref object of JSObj

# MutationObserver
proc newMutationObserver*(callback: proc ()): MutationObserver {.jsimportgWithName: "new MutationObserver".}
proc observe*(observer: MutationObserver, elem: Element, config: JSObj) {.jsimport.}
