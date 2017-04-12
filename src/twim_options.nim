
import jswrapper.basics

let savedirectoryElem = document.getElementById("save-directory")
let savedirectoryTextElem = document.getElementById("save-directory-text")
savedirectoryElem.addEventListener("change") do (e: Event):
  savedirectoryTextElem.innerText = savedirectoryElem.value
