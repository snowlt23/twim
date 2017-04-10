
import jsbind
import jswrapper

type
  MutationObserver* = ref object of JSObj

# MutationObserver
proc newMutationObserver*(callback: proc ()): MutationObserver {.jsimportgWithName: "new MutationObserver".}
proc observe*(observer: MutationObserver, elem: Element, config: JSObj) {.jsimport.}
