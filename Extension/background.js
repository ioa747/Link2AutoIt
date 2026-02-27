// background.js - v2
browser.runtime.onMessage.addListener((message) => {
    if (message.url) {
        // Instead of creating a new object from scratch, 
        // we send the entire message that came from content.js
        browser.runtime.sendNativeMessage("com.link2autoit.bridge", message)
            .then(response => {
                console.log("[Background] Reply from AutoIt:", response);
            })
            .catch(error => {
                console.error("[Background] Native Host Error:", error);
            });

        console.log("[Background] Forwarded Full Data to AutoIt");
    }
});