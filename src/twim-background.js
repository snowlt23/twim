
var switchFlag = false

function enableTwim(tab) {
    chrome.tabs.sendMessage(tab.id, "startTwim");
    chrome.browserAction.setIcon({path: "icon-enable.png"});
}
function disableTwim(tab) {
    chrome.tabs.sendMessage(tab.id, "endTwim");
    chrome.browserAction.setIcon({path: "icon-disable.png"});
}

chrome.browserAction.onClicked.addListener((tab) => {
    if (!switchFlag) {
        enableTwim(tab);
        switchFlag = true;
    } else {
        disableTwim(tab);
        switchFlag = false;
    }
});

