//
//  PDFTableDrawer.swift
//  SimplePDFBuilder
//
//  Created by MaksBelenko on 25/06/2020.
//
//  MIT License
//  Copyright (c) 2020 MaksBelenko
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import UIKit.UIGraphicsImageRenderer

internal final class PDFTableDrawer {
    
    // TODO: Update with the value of pageOffset in PDFBuilder
    var pageMargins: PDFMargins
    
    private typealias NoArgs = () -> ()
    private var startNewPage: NoArgs?
    
    private let pdfContext: UIGraphicsPDFRendererContext
    private let pageRect: CGRect
    private var tableType: TableStyle = .Modern
    private var textSpacing: CGFloat = 0
    
    private var columns: [TableColumn]!
    private var font: UIFont!
    private var themeColour: UIColor!
    
    private struct TableColumn {
        let offset: CGFloat
        let width: CGFloat
        let alignment: Alignment
    }
    
    
    // MARK: - Deinit
    
//    deinit {
//        print("DEBUG: PDFTableDrawer deinit is called")
//    }
    
    func releaseFuncReferences() {
        startNewPage = nil
    }
    
    
    
    // MARK: - Initialisation
    init(_ pageData: PageData, startNewPage: @escaping () -> ()) {
        pdfContext = pageData.pdfContext
        pageRect = pageData.pageRect
        pageMargins = pageData.pageMargins
        
        self.startNewPage = startNewPage
    }
    
    
    // MARK: - Public methods
    
    /**
     Draws table using headers and rows
     - Parameter headers: Headers which will be used in the table header
     - Parameter rows: Rows from which the table will be constructed
     - Parameter top: Top offset
     */
    func drawTable(headers: [PDFColumnHeader], rows: [PDFTableRow], font: UIFont, themeColour: UIColor, top: CGFloat) -> CGFloat {
        self.font = font
        self.themeColour = themeColour
        self.textSpacing = getSizeFor(text: "Tesg", font: font).height / 2
        
        columns = getSpacing(using: headers)
        
        var newTop: CGFloat = top
        newTop = drawHeader(headers: headers, top: newTop)
        newTop = drawRows(rows: rows, top: newTop)
        
        return newTop
    }
    
    
    func changeTableType(with tableType: TableStyle) {
        self.tableType = tableType
    }
    
    
    // MARK: - Draw Headers & Rows
    
    /**
     Draws header for the table
     */
    private func drawHeader(headers: [PDFColumnHeader], top: CGFloat) -> CGFloat {
        let textColour = getTextColour(forBackgroundColour: themeColour)
        
        let texts = headers.map { $0.text }
        let maxTextHeight = getMaxHeight(for: texts)
        
        var nTop = top
        let rowHeight = maxTextHeight + 2*textSpacing
        nTop = checkPageBounds(rowHeight: rowHeight, top: nTop)
        
        let newTop = drawHeaderShapes(height: rowHeight, textColour: textColour, top: nTop)
        
        drawRowOfTexts(with: texts, colour: textColour, top: nTop)
        
        return newTop
    }
    
    
    /**
     Draw all rows on the PDF
     */
    private func drawRows(rows: [PDFTableRow], top: CGFloat) -> CGFloat {
        var newTop = top
        var count: Int = 0
        
        for row in rows {
            count += 1
            
            let maxTextHeight = getMaxHeight(for: row.entries)
            let rowHeight = maxTextHeight + 2*textSpacing
            
            newTop = checkPageBounds(rowHeight: rowHeight, top: newTop)
            drawRowsShapes(count: count, height: rowHeight, top: newTop)
            drawRowOfTexts(with: row.entries, colour: .black, top: newTop)
            
            newTop += rowHeight
        }
        
        
        return newTop
    }
    

    

    
    // MARK: - Private methods
    
    /**
     Draws shapes for the header such as rectangle and separators
     */
    private func drawHeaderShapes(height: CGFloat, textColour: UIColor, top: CGFloat) -> CGFloat {
        
        let sepPoints = columns.map { $0.offset }
        let newTop: CGFloat
        
        switch tableType {
        case .Modern:
            newTop = drawRectWithCornerRadius(height: height, colour: themeColour , top: top)
        case .Strict:
            newTop = drawRect(height: height, colour: themeColour, top: top)
        }
        
        drawSeparators(points: sepPoints, height: height, colour: textColour, top: top)
        
        return newTop
    }
    
    
    private func drawRowsShapes(count: Int, height: CGFloat, top: CGFloat) {
        switch tableType {
        case .Modern:
            let lightColour = themeColour.withAlphaComponent(0.1)
            if (count % 2) == 0 {
                let _ = drawRectWithCornerRadius(height: height, colour: lightColour, top: top)
            }
        case .Strict:
            drawRowLines(height: height, top: top)
        }
    }
    
    
    
    
    /**
     Draws a row of text for the table
     */
    private func drawRowOfTexts(with texts: [String], colour: UIColor, top: CGFloat) {
        for i in 0..<columns.count {
            if i < texts.count {
                drawText(text: texts[i],
                         textColour: colour,
                         column: columns[i],
                         top: top + textSpacing)
            }
        }
    }
    
    
    /**
     Draw rectangle with corner radius
     - Parameter drawContext: Core Graphics context
     - Parameter pageRect: Page size rectangle
     - Parameter top: Top Offset
     */
    private func drawRectWithCornerRadius(height: CGFloat, colour: UIColor, top: CGFloat) -> CGFloat {
        let drawContext = pdfContext.cgContext
        drawContext.saveGState()
        
        drawContext.setFillColor(colour.cgColor)
        let rectWidth = pageRect.width - (pageMargins.left + pageMargins.right)
        let rect = CGRect(x: pageMargins.left, y: top, width: rectWidth, height: height)
        let roundedRect = UIBezierPath(roundedRect: rect, cornerRadius: 5).cgPath
        drawContext.addPath(roundedRect)
        drawContext.drawPath(using: .fill)
        
        drawContext.restoreGState()
        
        return top + rect.height
    }
    
    
    /**
     Draw rectangle
     - Parameter drawContext: Core Graphics context
     - Parameter pageRect: Page size rectangle
     - Parameter top: Top Offset
     */
    private func drawRect(height: CGFloat, colour: UIColor, top: CGFloat) -> CGFloat {
        let drawContext = pdfContext.cgContext
        drawContext.saveGState()
        
        drawContext.setFillColor(colour.cgColor)
        let rectWidth = pageRect.width - (pageMargins.left + pageMargins.right)
        let rect = CGRect(x: pageMargins.left, y: top, width: rectWidth, height: height)
        let path = UIBezierPath(rect: rect).cgPath
        drawContext.addPath(path)
        drawContext.drawPath(using: .fill)
        
        drawContext.restoreGState()
        
        return top + rect.height
    }
    
    
    /**
     Draw lines for Strict table style
     */
    private func drawRowLines(height: CGFloat, top: CGFloat) {
        var points = columns.map { $0.offset }
        
        points.append(pageRect.width - pageMargins.right - 0.5)
        points[0] = points[0] + 0.5
        
        let drawContext = pdfContext.cgContext
        drawContext.saveGState()
        
        drawContext.setLineWidth(1.0)
        drawContext.setStrokeColor(themeColour.cgColor)
        
        var lastPoint = CGPoint()
        
        for i in 0..<points.count {
            let point = points[i]
            lastPoint = CGPoint(x: point, y: top + height)
            drawContext.move(to: CGPoint(x: point, y: top))
            drawContext.addLine(to: CGPoint(x: point, y: top + height))
            drawContext.strokePath()
        }
        
        drawContext.move(to: CGPoint(x: points[0], y: top + height))
        drawContext.addLine(to: lastPoint)
        drawContext.strokePath()
        
        drawContext.restoreGState()
    }
    
    
    /**
     Draws separater lines between table columns
     - Parameter points: Points of separation
     - Parameter colour: Separation line colour
     - Parameter top: Top offset
     */
    private func drawSeparators(points: [CGFloat], height: CGFloat, colour: UIColor, top: CGFloat) {
        let drawContext = pdfContext.cgContext
        drawContext.saveGState()
        
        drawContext.setLineWidth(1.0)
        drawContext.setStrokeColor(colour.cgColor)
        
        for i in 1..<points.count {
            let point = points[i]
            drawContext.move(to: CGPoint(x: point, y: top))
            drawContext.addLine(to: CGPoint(x: point, y: top + height))
            drawContext.strokePath()
        }
        
        drawContext.restoreGState()
    }
    
    
    
    /**
     Draws text
     */
    private func drawText(text: String, textColour: UIColor,
                          column: TableColumn, top: CGFloat)  {
        
        let textAttributes = [NSAttributedString.Key.foregroundColor : textColour,
                              NSAttributedString.Key.font: font! ]

        let attributedText = NSAttributedString(string: text, attributes: textAttributes)
        let textStringSize = attributedText.size()

        let xOffset = getTextXOffset(for: column, stringWidth: textStringSize.width)
        
        let textStringRect = CGRect(x: xOffset,
                                    y: top,
                                    width: textStringSize.width,
                                    height: textStringSize.height)

        attributedText.draw(in: textStringRect)
    }
    
    
    /**
     Check the bounds of the PDF page
     - Parameter rowHeight: Height of the object
     - Parameter top: The top offset
     - Returns: New top offset if the object will go out of bounds
     */
    private func checkPageBounds(rowHeight: CGFloat, top: CGFloat) -> CGFloat {
        var newTop = top
        
        if (newTop > (pageRect.height - (rowHeight + pageMargins.bottom)) ) {
            startNewPage!()
            newTop = pageMargins.top
        }
        
        return newTop
    }
    
    
    // MARK: - Helpers
    
    /**
     Get maximum size for of all texts
     - Parameter entries: Either headers or rable rows
     - Returns: Maximum height of all entries
     */
    private func getMaxHeight(for entries: [String]) -> CGFloat {
        var maxTextHeight: CGFloat = 0
        for entry in entries {
            let height = getSizeFor(text: entry, font: font).height
            if (height > maxTextHeight) {
                maxTextHeight = height
            }
        }
        
        return maxTextHeight
    }
    
    
    /**
     Gets the size for the used font
     - Parameter text: Text
     - Parameter font: Font used
     - Returns: size as CGSize
     */
    private func getSizeFor(text: String, font: UIFont) -> CGSize {
        let t = (text == "") ? "Test String" : text
        let attributedText = NSAttributedString(string: t, attributes: [NSAttributedString.Key.font: font])
        return attributedText.size()
    }
    
    
    /**
     Creates spacing by passing headers data
     - Parameter headers: Array of PDFHeader which contains weight and alignment
                        used for table columns creation
     - Returns: TableColumn struct containing: x-offset, width and alignment of the table column
     */
    private func getSpacing(using headers: [PDFColumnHeader]) -> [TableColumn] {
        let width = pageRect.width - (pageMargins.left + pageMargins.right)
        let columnsCount = headers.count
        
        let weightsTotal = CGFloat(headers.map { $0.weight }
                                          .reduce(0, +) )
        let minWeightWidth = width / weightsTotal
        
        var tableColumns = [TableColumn(offset: pageMargins.left,
                                        width: minWeightWidth * CGFloat(headers[0].weight),
                                        alignment: headers[0].alignment )]
        for i in 1..<columnsCount {
            tableColumns.append(TableColumn(offset: tableColumns[i-1].offset + tableColumns[i-1].width,
                                            width: minWeightWidth * CGFloat(headers[i].weight),
                                            alignment: headers[i].alignment ))
        }
        
        return tableColumns
    }
    
    
    /**
     Gets the colour for text depending on background colour
     - Parameter bc: Passed background colour
     - Returns: Colour that will be seen on background colour
     */
    private func getTextColour(forBackgroundColour bc: UIColor) -> UIColor {
        let rgb = bc.rgba
        let luminance = (0.299 * rgb.red + 0.587 * rgb.green + 0.114 * rgb.blue)
        
        let d = (luminance > 0.5) ? 0 : 255
        
        return UIColor(red: d, green: d, blue: d)
    }
    
    
    
    /**
     Gets x-axis offset depending on the column alignment
     - Parameter column: Column that is used
     - Parameter stringWidth: Width of the text
     - Returns: A new offset depending on the column alignment
     */
    private func getTextXOffset(for column: TableColumn, stringWidth: CGFloat) -> CGFloat {
        switch column.alignment {
        case .left:
            return column.offset + 10
        case .centre:
            return column.offset + (column.width - stringWidth)/2
        case .right:
            return column.offset + (column.width - stringWidth) - 10
        }
    }
    
}
