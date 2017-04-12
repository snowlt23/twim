
import macros
import boost.richstring, strutils, sequtils

let stmts {.compileTime.} = ident"stmts"
let bodystmts {.compileTime.} = ident"bodystmts"
let generated {.compileTime.} = ident"generated"
let argsid {.compileTime.} = ident"args"
let argid {.compileTime.} = ident"arg"
let resultid {.compileTime.} = ident"result"

proc getString*(node: NimNode): string {.compileTime.} =
  if node.kind == nnkSym:
    node.symbol.getImpl.strval
  else:
    node.strval

proc genBodyStmt*(target: NimNode, body: NimNode): NimNode {.compileTime.} =
  result = newStmtList()
  for b in body.children:
    var e = b.copy
    if e.kind == nnkForStmt:
      let forbody = e[^1]
      e[^1] = quote do:
        when compiles(`target`.add(`forbody`)):
          `target`.add(`forbody`)
        else:
          `forbody`
    result.add quote do:
      when compiles(`target`.add(`e`)):
        `target`.add(`e`)
      else:
        `e`
proc genAttrExpr*(name: string, valnode: NimNode): NimNode {.compileTime.} =
  if valnode == nil:
    return newEmptyNode()
  result = quote do:
    `generated`.add(" ")
    `generated`.add(`name`)
    `generated`.add("=")
    `generated`.add("\"" & `valnode` & "\"")

proc genOpenBracket*(): NimNode {.compileTime.} =
  result = quote do:
    `generated`.add("<")
proc genTag*(tag: string): NimNode {.compileTime.} =
  result = quote do:
    `generated`.add(`tag`)
proc genCloseBracket*(): NimNode {.compileTime.} =
  result = quote do:
    `generated`.add(">")

proc genCloseTag*(tag: string): NimNode {.compileTime.} =
  result = quote do:
    `generated`.add("</" & `tag` & ">")

proc genHTMLClosure*(stmts: NimNode): NimNode {.compileTime.} =
  result = quote do:
    (proc (): string =
      var `generated` = ""
      `stmts`
      return `generated`
    )()

proc genAttr*(valnode: NimNode): NimNode {.compileTime.} =
  result = quote do:
    `generated`.add(" ")
    `generated`.add(`valnode`)

proc genTagMacroBody*(tag: NimNode, attrs: seq[string]): NimNode {.compileTime.} =
  var attrcheckstmt = newStmtList()
  attrcheckstmt.add quote do:
    if $`argid`[0] == "attr":
      `stmts`.add(genAttr(`argid`[1]))
      continue
  for attr in attrs:
    let attrstr = newStrLitNode(attr)
    attrcheckstmt.add quote do:
      if $`argid`[0] == `attrstr`:
        `stmts`.add(genAttrExpr(`attrstr`, `argid`[1]))
        continue

  result = quote do:
    case `argid`.kind
    of nnkExprEqExpr:
      `attrcheckstmt`
      error "unknown tag: ", `argid`
    of nnkStmtList:
      `bodystmts`.add(genBodyStmt(`generated`, `argid`))
    else:
      let stmts = newStmtList()
      stmts.add(`argid`)
      `bodystmts`.add(genBodyStmt(`generated`, stmts))

macro defineTag*(tag: untyped, attrstr: string, tagname: string = nil): untyped =
  tag.expectKind nnkIdent
  let actualtag = if tagname != nil: tagname else: tag
  let attrs = attrstr.getString.split(" ")
  let exporttag = tag.postfix("*")
  let tagstr = newStrLitNode($actualtag)
  let body = genTagMacroBody(actualtag, attrs)
  result = quote do:
    macro `exporttag`(`argsid`: varargs[untyped]): untyped =
      var `stmts` = newStmtList()
      var `bodystmts` = newStmtList()
      `stmts`.add(genOpenBracket())
      `stmts`.add(genTag(`tagstr`))
      for i in 0..<`argsid`.len:
        let `argid` = `argsid`[i]
        `body`
      `stmts`.add(genCloseBracket())
      `stmts`.add(`bodystmts`)
      `stmts`.add(genCloseTag(`tagstr`))
      `resultid` = genHTMLClosure(`stmts`)

proc removePostfix*(id: NimNode): NimNode =
  if id.kind == nnkPostfix:
    return id[1]
  else:
    return id

proc getMixinArgs*(procdef: NimNode): seq[string] {.compileTime.} =
  result = @[]
  let args = procdef[3]
  for i in 1..<args.len-1:
    result.add($args[i][0])

proc genMixinProcStmt*(procname: string, args: openarray[NimNode], body: NimNode): NimNode {.compileTime.} =
  var stmts = newStmtList()

  let mixinid = ident"mixincontent"

  var proccall = newCall(ident(procname))
  for arg in args:
    proccall.add(arg)
  proccall.add(mixinid)

  stmts.add quote do:
    var `mixinid` = ""
  stmts.add(genBodyStmt(mixinid, body))
  stmts.add quote do:
    return `proccall`

  result = quote do:
    (proc (): string = 
      `stmts`
    )()
  #[
    (proc (): string =
      var mixincontent = ""
      when compiles(mixincontent.add("first body argument")):
        mixincontent.add("first body argument")
      else:
        "first body argument"
      when compiles(mixincontent.add("second body argument")):
        mixincontent.add("second body argument")
      else:
        "second body argument"
      return procMixin("first argument", "second argument", mixincontent)
  ]#

proc genMixinMacroArgs*(procdef: NimNode): NimNode {.compileTime.} =
  result = nnkFormalParams.newTree()
  let args = procdef[3]
  result.add(ident"untyped")
  for i in 1..<args.len-1:
    result.add(args[i])
  result.add nnkIdentDefs.newTree(
    ident"body",
    ident"untyped",
    newEmptyNode(),
  )
proc genMixinMacroStmt*(procdef: NimNode): NimNode {.compileTime.} =
  result = newStmtList()
  let procname = newStrLitNode($procdef[0].removePostfix & "Mixin")
  let args = procdef.getMixinArgs()
  let resultid = ident"result"
  let bodyid = ident"body"

  let bracketargs = nnkBracket.newTree()
  for arg in args:
    bracketargs.add(ident(arg))

  result.add quote do:
    `resultid` = genMixinProcStmt(`procname`, `bracketargs`, `bodyid`)
  #[
    result = genMixinProcStmt("procMixin", [firstarg, secondarg], body)
  ]#

macro template_mixin*(procdef: untyped): untyped =
  result = newStmtList()
  result.add nnkMacroDef.newTree(
    procdef[0],
    newEmptyNode(),
    newEmptyNode(),
    genMixinMacroArgs(procdef),
    newEmptyNode(),
    newEmptyNode(),
    genMixinMacroStmt(procdef),
  )
  var procdefcopy = procdef.copy
  procdefcopy[0] = ident($procdefcopy[0].removePostfix & "Mixin").postfix("*")
  result.add(procdefcopy)
  #[
    macro procname*(firstarg: string, secondarg: string, body: untyped): untyped =
      ...
    proc procMixin*(firstarg: string, secondarg: string, mixincontent: string): string =
      ...
  ]#

proc mergeAttr*(a, b: string): string {.compileTime.} =
  a & " " & b

const defaultAttr* = "id class style"

const br* = "<br>"
defineTag(html, "lang")
defineTag(head, "")
defineTag(title, "")
defineTag(meta, "charset")
defineTag(body, "")
defineTag(d, defaultAttr, tagname="div")
defineTag(span, defaultAttr)
defineTag(h1, defaultAttr)
defineTag(h2, defaultAttr)
defineTag(h3, defaultAttr)
defineTag(h4, defaultAttr)
defineTag(p, defaultAttr)
defineTag(a, defaultAttr.mergeAttr("href"))
defineTag(button, defaultAttr)
defineTag(input, defaultAttr.mergeAttr("type value"))
defineTag(label, defaultAttr.mergeAttr("for"))
defineTag(link, defaultAttr.mergeAttr("rel type href"))
defineTag(script, defaultAttr.mergeAttr("type src"))
defineTag(img, defaultAttr.mergeAttr("src width height"))

when isMainModule:
  proc gen(): string =
    html(lang="ja"):
      for i in 0..<5:
        d:
          a(href="#"): fmt"test${i}"
  echo gen()
  proc base(mixincontent: string): string {.template_mixin.} =
    html(lang="ja"):
      head:
        title: "hello!"
      for i in 0..<5:
        d:
          mixincontent
  proc genmixin(): string =
    base:
      "test!!"
  echo genmixin()
