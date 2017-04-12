
var switchFlag = false

function enableTwim(tab) {
    chrome.tabs.sendMessage(tab.id, "enableTwim");
    chrome.browserAction.setIcon({path: "icon-enable.png"});
}
function disableTwim(tab) {
    chrome.tabs.sendMessage(tab.id, "disableTwim");
    chrome.browserAction.setIcon({path: "icon-disable.png"});
}

chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
    let savedirectory = localStorage.getItem("save-directory");
    if (savedirectory === null) {
        savedirectory = "";
    }
    if (savedirectory !== "") {
        savedirectory += "/";
    }
    if (request.type == "download") {
        chrome.downloads.download({
            "url": request.url,
            "filename": savedirectory + request.filename
        });
    }
});

chrome.browserAction.onClicked.addListener((tab) => {
    if (!switchFlag) {
        enableTwim(tab);
        switchFlag = true;
    } else {
        disableTwim(tab);
        switchFlag = false;
    }
});

