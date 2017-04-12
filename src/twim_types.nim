
import jsbind
import jsdecl.basics

type
  DownloadMessage* = ref object of JSObj

proc messagetype*(msg: DownloadMessage): jsstring {.jsimportProp.}
proc url*(msg: DownloadMessage): jsstring {.jsimportProp.}
proc filename*(msg: DownloadMessage): jsstring {.jsimportProp.}
    
