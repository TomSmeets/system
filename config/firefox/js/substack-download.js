// ==UserScript==
// @name         Substack Download
// @namespace    tsmeets.nl
// @version      2023-12-25
// @description  Add a download button to substack posts, To save the Video press Ctrl+S
// @author       Tom Smeets <tom@tsmeets.nl>
// @match        https://*.substack.com/*
// @match        https://www.computerenhance.com/*
// @grant        none
// ==/UserScript==

(function (){
    'use strict';
    const e = window?._preloads?.post?.video_upload_id || window?.wrappedJSObject?._preloads?.post?.video_upload_id || null;
    if(e) {
        const o = document.querySelector(".video-player");
        o.insertAdjacentHTML("afterend",`<a href="/api/v1/video/upload/${e}/src?type=mp4" target="_blank" download="very_cool_filename.mp4">Download Video</a>`);
    }
})();
