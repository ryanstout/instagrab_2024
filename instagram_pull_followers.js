(async function() {

var search = document.querySelector("input[placeholder='Search']");

// get the node after search
var scrollBox = search.parentNode.parentNode.nextSibling;

// Find followers did (first div with display: flex)
var followersDiv = scrollBox.childNodes[0].childNodes[0];

var lines = followersDiv.childNodes;
console.log(lines.length);

// Go one node up from the first line
var parent = lines[0].parentNode.parentNode.parentNode;

// Slowly scroll the parent div until no more lines are added
var lastLength = lines.length;
var currentLength = 0;

console.log('start scrolling')
var noMoveTicks = 0;
for (;;) {
    lastLength = currentLength;
    console.log('scroll height: ', parent.scrollHeight)
    parent.scrollTop = parent.scrollHeight;
    await new Promise(r => setTimeout(r, 1000 + (Math.random() * 2000)));
    lines = followersDiv.childNodes;
    currentLength = lines.length;
    console.log(currentLength);

    if (currentLength == lastLength) {
        noMoveTicks++;
        console.log('not moving: ', noMoveTicks)
        if (noMoveTicks > 5) {
            console.log('not moving, breaking')
            break;
        }
    }
}

console.log('done scrolling')
// grab all links from each line that have the url in the format of /*username*/
var links = [];
for (var i = 0; i < lines.length; i++) {
    var line = lines[i];
    line.querySelectorAll("a").forEach(function (link) {
        var url = link.href;
        console.log(url);
        if (url && url.match(/https[:]\/\/\www.instagram.com\/[a-zA-Z0-9_\.]+/)) {
            // pull out just the username
            url = url.replace(/https[:]\/\/\www.instagram.com\//, "");

            url = url.replace(/\//, "");

            // don't add if the url is already in there
            if (links.indexOf(url) === -1) {
                links.push(url);
            }
        }
    });
}

console.log(JSON.stringify(links));
// Call the callback
arguments[0](links)
// return links;
})();