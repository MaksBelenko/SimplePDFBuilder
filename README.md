<img src="Docs/Images/pdfPreview.png" align="right" height=500px/>

# SimplePDFBuilder


## Adding Text

```swift
let pdf = PDFBuilder()

pdf.holdLine()
pdf.addText(text: "SHIP TO:", alignment: .left, font: .boldArial(ofSize: 14))
pdf.addText(text: "BILL TO:", alignment: .right, font: .boldArial(ofSize: 14))
pdf.releaseLine()
        
pdf.holdLine()
pdf.addText(text: "John Doe", alignment: .left, font: .arial(ofSize: 11))
pdf.addText(text: "John Doe", alignment: .right, font: .arial(ofSize: 11))
pdf.releaseLine()

let pdfData = pdf.build()
```

## License

[![License](http://img.shields.io/:license-mit-blue.svg?style=flat-square)](http://badges.mit-license.org)

- **[MIT license](http://opensource.org/licenses/mit-license.php)**
- Copyright 2020 © <a href="https://github.com/MaksBelenko" target="_blank">MaksBelenko</a>.