
import jswrapper.basics
import jswrapper.localstorages

let savedirectoryElem = document.getElementById("save-directory")
let savesettingsElem = document.getElementById("save-settings")

savedirectoryElem.value = localStorage.getStringItem("save-directory")

savesettingsElem.addEventListener("click") do (e: Event):
  let savedirectory = savedirectoryElem.value
  localStorage.setStringItem("save-directory", savedirectory)
