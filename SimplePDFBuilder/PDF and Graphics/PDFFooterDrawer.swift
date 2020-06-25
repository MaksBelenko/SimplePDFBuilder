//
//  PDFFooterDrawer.swift
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

internal final class PDFFooterDrawer {
    
    private let pdfContext: UIGraphicsPDFRendererContext
    private let pageRect: CGRect
    
    // TODO: Update with the value of pageOffset in PDFBuilder
    var pageMargins: PDFMargins
    
    /// Eables drawing of page footer
    var footer = PDFFooter(isEnabled: false, pagingEnabled: false, text: "", colour: .black)
    private let pdfTextDrawer: PDFTextDrawer
    
    
    // MARK: - Initialisation
    init(_ pageData: PageData) {
        pdfContext = pageData.pdfContext
        pageRect = pageData.pageRect
        pageMargins = pageData.pageMargins
        
        pdfTextDrawer = PDFTextDrawer(pageData)
    }
    
    
    // MARK: - Public methods
    
    func drawFooterIfNeeded() {
        if footer.isEnabled {
            let top = pageRect.height - pageMargins.bottom
            
            let context = pdfContext.cgContext
            context.saveGState()
            
            context.setFillColor(footer.colour.cgColor)
            let rectWidth = pageRect.width - (pageMargins.left + pageMargins.right)
            let rect = CGRect(x: pageMargins.left, y: top, width: rectWidth, height: 0.25)
            let path = UIBezierPath(rect: rect).cgPath
            context.addPath(path)
            context.drawPath(using: .fill)
            
            context.restoreGState()
            
            if footer.text != "" {
                let _ = pdfTextDrawer.drawText(text: footer.text,
                                               font: .systemFont(ofSize: 9),
                                               color: footer.colour,
                                               lineSpacing: 0,
                                               alignment: .left,
                                               top: top + 12)
            }
            
            if footer.pagingEnabled {
                numberThePage(font: .systemFont(ofSize: 9), colour: footer.colour)
            }
        }
    }
    
    
    // MARK: - Private methods
    /**
     Numbers the page and increases the page counter
     */
    private func numberThePage(font: UIFont, colour: UIColor) {
        let _ = pdfTextDrawer.drawText(text: "\(footer.pageNumber)", font: font, color: colour, alignment: .right, top: pageRect.height - pageMargins.bottom + 12)
        footer.pageNumber += 1
    }
}
