
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

template defineJsGlobal*(name, typ) =
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
  echo T.repr
  if T.len == 0 and T.kind != nnkSym:
    return false
  let typeimpl = if T.kind == nnkSym:
                   T.symbol.getImpl
                 else:
                   T[0].symbol.getImpl()
  if typeimpl.len < 3:
    return false
  if typeimpl[2].kind == nnkRefTy and typeimpl[2][0][1].kind == nnkOfInherit and typeimpl[2][0][1][0].repr == "JSObj":
    return true
  else:
    return false

proc procToTemplate*(procdef: NimNode): NimNode {.compileTime.} =
  result = nnkTemplateDef.newTree(
    procdef[0],
    procdef[1],
    procdef[2],
    procdef[3],
    procdef[4],
    procdef[5],
    procdef[6],
  )

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
      VT = procdef[3][0]
    let emasmstr = "\"return $0[$1]\""
    let pstr = fmt"emTypeToNimType(${VT.repr}, EM_ASM_INT(${emasmstr}, toEmPtr(${Tname}), toEmPtr(${ATname})))"
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
      VTname = procdef[3][3][0]
    let emasmstr= "\"$0[$1] = $2\""
    let pstr= fmt"discard EM_ASM_INT(${emasmstr}, toEmPtr(${Tname}), toEmPtr(${ATname}), toEmPtr(${VTname}))"
    procbody.add(parseExpr(pstr))
    result[6] = procbody

macro jsaccessor*(procdef: untyped): untyped =
  if $procdef[0].removePostfix() == "[]":
    result = genArrayGetter(procdef)
  elif $procdef[0].removePostfix() == "[]=":
    result = genArraySetter(procdef)
  echo result.repr
