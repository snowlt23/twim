
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

task "copy-files", "":
  copyFile "manifest.json", "dist/manifest.json"
  copyFile "src/twim-background.js", "dist/twim-background.js"

task "generate-loader", "":
  generateEmbeddedWasm("dist/twim.wasm", "dist/twim-loader.js")

task "build", "build wasm":
  runTask "copy-files"
  discard execShellCmd "nim c -o:dist/twim.js src/twim.nim"
  runTask "generate-loader"
