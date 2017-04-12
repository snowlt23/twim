
import nake
import os
import strutils
import sequtils

proc generateEmbeddedWasm*(filename: string, distname: string) =
  let wasmstr = readFile(filename)
  var binarray = newSeq[string]()
  for c in wasmstr:
    binarray.add($c.uint8)
  
  let loaderstr = readFile("src/twim-loader.js")
  writeFile(distname, loaderstr.replace("${WASM_BINARY_ARRAY}", binarray.join(",")))

proc install*(package: string) =
  discard execShellCmd("nimble install" & package)

task "install-depends", "":
  install "jsbind"
  install "nimboost"

task "copy-files", "":
  copyFile "manifest.json", "dist/manifest.json"
  copyFile "images/icon-enable.png", "dist/icon-enable.png"
  copyFile "images/icon-disable.png", "dist/icon-disable.png"

task "generate-options", "":
  discard execShellCmd "nim c -r src/twim_options_html.nim"
  discard execShellCmd "nim js -o:dist/twim-options.js src/twim_options.nim"

task "generate-background", "":
  discard execShellCmd "nim js -o:dist/twim-background.js src/twim_background.nim"

task "generate-loader", "embed wasm to loader":
  generateEmbeddedWasm("dist/twim.wasm", "dist/twim-loader.js")

task "build", "build wasm":
  runTask "copy-files"
  runTask "generate-options"
  runTask "generate-background"
  discard execShellCmd "nim c -d:emscripten -o:dist/twim.js src/twim.nim"
  runTask "generate-loader"

task "package", "packaging extension for publish":
  runTask "build"
  discard execShellCmd "zip -r -j Twim.zip dist"

