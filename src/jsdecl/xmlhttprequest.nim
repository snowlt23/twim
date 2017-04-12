
import jsbind

type XMLHTTPRequest* = ref object of JSObj # Define the type. JSObj should be the root class for such types.

proc newXMLHTTPRequest*(): XMLHTTPRequest {.jsimportgWithName: "function(){return (window.XMLHttpRequest)?new XMLHttpRequest():new ActiveXObject('Microsoft.XMLHTTP')}".}

proc open*(r: XMLHTTPRequest, httpMethod, url: jsstring, b: bool) {.jsimport.}
proc send*(r: XMLHTTPRequest) {.jsimport.}
proc send*(r: XMLHTTPRequest, body: jsstring) {.jsimport.}

proc addEventListener*(r: XMLHTTPRequest, event: jsstring, listener: proc()) {.jsimport.}
proc setRequestHeader*(r: XMLHTTPRequest, header, value: jsstring) {.jsimport.}

proc responseText*(r: XMLHTTPRequest): jsstring {.jsimportProp.}
proc statusText*(r: XMLHTTPRequest): jsstring {.jsimportProp.}

proc `responseType=`*(r: XMLHTTPRequest, t: jsstring) {.jsimportProp.}
proc response*(r: XMLHTTPRequest): JSObj {.jsimportProp.}
