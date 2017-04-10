
import nake
import os
import strutils
import sequtils

task "copy-manifest", "":
  copyFile "manifest.json", "dist/manifest.json"

task "generate-loader", "":
  let wasmstr = readFile("dist/twim.wasm")
  var binarray = newSeq[string]()
  for c in wasmstr:
    binarray.add($c.uint8)
  
  let loaderstr = readFile("src/twim-loader.js")
  writeFile("dist/twim-loader.js", loaderstr.replace("${WASM_BINARY_ARRAY}", binarray.join(",")))

task "build", "build wasm":
  runTask "copy-manifest"
  runTask "generate-loader"
  discard execShellCmd "nim c -o:dist/twim.js src/twim.nim"
