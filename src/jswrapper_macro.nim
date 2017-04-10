
import macros
import boost.richstring

import jsbind
when defined(emscripten):
  import jsbind.emscripten
  export emscripten

proc removePostfix*(node: NimNode): NimNode {.compileTime.} =
  if node.kind == nnkPostfix:
    return node[1]
  else:
    return node

template defineJSGlobal*(name, typ) =
  when defined(js):
    var name* {.importc, nodecl.}: typ
  elif defined(emscripten):
    var name* = globalEmbindObject(typ, astToStr(name))

proc finalizeEmbindObject*(o: JSObj) =
  discard EM_ASM_INT("delete _nimem_o[$0]", o.p)
template newEmbindObject*[T](emref: untyped): T =
  var tmp: T
  tmp.new(cast[proc(o: T){.nimcall.}](finalizeEmbindObject))
  tmp.p = emref
  tmp

template toEmPtr*(s: cstring): cstring = cstring(s)
template toEmPtr*(s: int | uint | cint | int32 | uint32 | uint16 | int16 | bool): cint = cint(s)
template toEmPtr*(s: JSObj): cint = s.p
template toEmPtr*(s: float | float32 | float64 | cfloat | cdouble): cdouble = cdouble(s)
template emTypeToNimType*[T](v: untyped): T =
  when T is JSObj:
    newEmbindObject[T](v)
  elif T is string:
    cast[string](v)
  else:
    T(v)

proc isJSObj*(T: NimNode): bool {.compileTime.} =
  case getType(T)[1].repr
  of "cstring":
    false
  of "int", "uint", "cint", "int32", "uint32", "uint16", "int16", "bool":
    false
  of "float", "float32", "float64", "cfloat", "cdouble":
    false
  else:
    true

proc emasmStrFromType*(T: NimNode, i: string): string {.compileTime.} =
  if T.isJSObj:
    return fmt"_nimem_o[${i}]"
  else:
    return i

macro expandGetterEMASMStr*(AT: typed, VT: typed): untyped =
  let
    arg1 = "$0"
    arg2 = emasmStrFromType(AT, "$1")
  if getType(VT).isJSObj:
    result = newStrLitNode(fmt"return _nimem_w(_nimem_o[${arg1}][${arg2}]);")
  else:
    result = newStrLitNode(fmt"return _nimem_o[${arg1}][${arg2}];")

macro expandSetterEMASMStr*(AT: typed, VT: typed): untyped =
  let
    arg1 = "$0"
    arg2 = emasmStrFromType(AT, "$1")
    arg3 = emasmStrFromType(VT, "$2")
  result = newStrLitNode(fmt"_nimem_o[${arg1}][${arg2}] = ${arg3}")

proc genArrayGetter*(procdef: NimNode): NimNode {.compileTime.} =
  if procdef[3].len != 3:
    error "violation proc arguments", procdef
  # result = procToTemplate(procdef)
  result = procdef.copy
  when defined(js):
    result.addPragma(nnkExprColonExpr.newTree(ident"importcpp", newStrLitNode("#[#]")))
    result.addPragma(ident"nodecl")
  elif defined(emscripten):
    var procbody = newStmtList()
    let
      Tname = procdef[3][1][0]
      ATname = procdef[3][2][0]
      AT = procdef[3][2][1]
      VT = procdef[3][0]
    let pstr = fmt"return emTypeToNimType[${VT.repr}](EM_ASM_INT(expandGetterEMASMStr(${AT.repr}, ${VT.repr}), toEmPtr(${Tname}), toEmPtr(${ATname})))" # FIX: genArrayGetter toEmPtr(${ATname})
    procbody.add(parseExpr(pstr))
    result[6] = procbody

proc genArraySetter*(procdef: NimNode): NimNode {.compileTime.} =
  if procdef[3].len != 4:
    error "violation proc arguments", procdef
  # result = procToTemplate(procdef)
  result = procdef.copy
  when defined(js):
    result.addPragma(nnkExprColonExpr.newTree(ident"importcpp", newStrLitNode("#[#] = #")))
    result.addPragma(ident"nodecl")
  elif defined(emscripten):
    var procbody = newStmtList()
    let
      Tname = procdef[3][1][0]
      ATname = procdef[3][2][0]
      AT = procdef[3][2][1]
      VTname = procdef[3][3][0]
      VT = procdef[3][3][1]
    let pstr= fmt"discard EM_ASM_INT(expandSetterEMASMStr(${AT.repr}, ${VT.repr}), toEmPtr(${Tname}), toEmPtr(${ATname}), toEmPtr(${VTname}))"
    procbody.add(parseExpr(pstr))
    result[6] = procbody

macro jsaccessor*(procdef: untyped): untyped =
  if $procdef[0].removePostfix() == "[]":
    result = genArrayGetter(procdef)
  elif $procdef[0].removePostfix() == "[]=":
    result = genArraySetter(procdef)
