options.dependencies.forEach(function(dep) {
  if (dep.src.indexOf("plugin/highlight/highlight.js") == -1) {
    return
  }
  var cb = dep.callback
  dep.callback = function() {
    // more brackets @ https://unicode-table.com/en/search/?q=bracket
    [].forEach.call(document.querySelectorAll('section[data-markdown] pre code'), function(v) {
      var lines = v.innerHTML.split('\n')
      res = ""
      for (var i = 0; i < lines.length; i++) {
        var line = lines[i]
        if (line == '﹇') {
          res += `<span class="fragment">`
        } else if (line == '⎵') {
          res += `</span>`
        } else {
          res += line
            .replace('⁅','<span class="fragment highlight-halffade">')
            .replace('⁆','</span>') + "\n"
        }
      }
      v.innerHTML = res.trim()
    })
    cb();
  }
})
