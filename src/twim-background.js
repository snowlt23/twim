
var switchFlag = false

chrome.browserAction.onClicked.addListener((tab) => {
    chrome.tabs.sendMessage(tab.id, "switchTwim");
});

