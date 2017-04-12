
import jsdecl.basics
import jsdecl.localstorages

let savedirectoryElem = document.getElementById("save-directory")
let savesettingsElem = document.getElementById("save-settings")
let savestatusElem = document.getElementById("save-status")

proc saveStatusIntoSuccess*() =
  savestatusElem.innerText = "設定が保存されました!"
  savestatusElem.style.color = "#90EE90" # LightGreen
  setTimeout(5000) do ():
    savestatusElem.innerText = ""
proc saveStatusIntoFailure*() =
  savestatusElem.innerText = "設定を保存できませんでした"
  savestatusElem.style.color = "#FA8072" # Salmon
  setTimeout(5000) do ():
    savestatusElem.innerText = ""

savedirectoryElem.value = localStorage.getStringItem("save-directory")

savesettingsElem.addEventListener("click") do (e: Event):
  let savedirectory = savedirectoryElem.value
  localStorage.setStringItem("save-directory", savedirectory)
  saveStatusIntoSuccess()
