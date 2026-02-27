// content.js - v2
let hoverTimer;

document.addEventListener('mouseover', (e) => {
    const target = e.target;
    const link = target.closest('a');
    
    // Check if the cursor is a pointer (hand)
    const isPointer = window.getComputedStyle(target).cursor === 'pointer';
    
    let mediaUrl = null;
    let mediaType = "LINK";
    let domain = "";

    // Case A: Hovering over an Image
    if (target.tagName === 'IMG') {
        mediaUrl = target.src;
        mediaType = "IMAGE";
        try { domain = new URL(target.src).hostname; } catch(err) { domain = ""; }
    } 
    // Case B: Hovering over a Link (only if it has a pointer cursor)
    else if (link && isPointer) {
        mediaUrl = link.href;
        mediaType = "LINK";
        domain = link.hostname;
    }

    // Only process valid http/https URLs
    if (mediaUrl && mediaUrl.startsWith('http')) {
        clearTimeout(hoverTimer);
        
        hoverTimer = setTimeout(() => {
            browser.runtime.sendMessage({ 
                action: "NATIVE_RELAY", 
                type: "HOVER",
                mediaType: mediaType,
                url: String(mediaUrl),
                domain: domain,
                text: (target.alt || (link ? link.innerText : "")).trim().substring(0, 100),
                title: document.title
            });
        }, 250); // Delay to ensure intentional hover
    }
}, true);

document.addEventListener('mouseout', () => clearTimeout(hoverTimer));

// Handle Clicks
document.addEventListener('click', (e) => {
    const link = e.target.closest('a');
    if (link && link.href && link.href.startsWith('http')) {
        browser.runtime.sendMessage({ 
            action: "NATIVE_RELAY", 
            type: "CLICK", 
            mediaType: "LINK",
            url: String(link.href),
            domain: link.hostname,
            text: link.innerText.trim().substring(0, 100),
            title: document.title
        });
    }
}, true);
