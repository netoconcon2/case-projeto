var Trix = require("trix");

Trix.config.blockAttributes.heading2 = {
  tagName: 'h2',
  terminal: true,
  breakOnReturn: true,
  group: false
}

Trix.config.blockAttributes.heading3 = {
  tagName: 'h3',
  terminal: true,
  breakOnReturn: true,
  group: false
}

Trix.config.textAttributes.underline = {
  tagName: 'u',
  inheritable: true,
  parser: function(element) {
    let style = window.getComputedStyle(element);
    return style.textDecoration.match(/underline/);
  }
}
Trix.config.textAttributes.highlight = {
  tagName: 'span',
  inheritable: true
}
// Trix.config.textAttributes.highlight2 = {
//   tagName: 'span',
//   inheritable: true
// }

export default Trix;