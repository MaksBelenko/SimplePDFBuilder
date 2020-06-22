//
//  PDFFooterDrawer.swift
//  SimplePDFBuilder
//
//  Created by Maksim on 22/06/2020.
//  Copyright © 2020 Maksim Belenko. All rights reserved.
//

import UIKit.UIGraphicsImageRenderer

internal final class PDFFooterDrawer {
    
    private let pdfContext: UIGraphicsPDFRendererContext
    private let pageRect: CGRect
    
    // TODO: Update with the value of pageOffset in PDFBuilder
    var pageOffset = PDFMargins(top: 72, left: 72, right: 72, bottom: 72)
    
    /// Eables drawing of page footer
    var footer = PDFFooter(isEnabled: false, pagingEnabled: false, text: "", colour: .black)
    private let pdfTextDrawer: PDFTextDrawer
    
    
    // MARK: - Initialisation
    init(context: UIGraphicsPDFRendererContext, pageRect: CGRect) {
        pdfContext = context
        self.pageRect = pageRect
        pdfTextDrawer = PDFTextDrawer(context: context, pageRect: pageRect)
    }
    
    
    // MARK: - Public methods
    
    func drawFooterIfNeeded() {
        if footer.isEnabled {
            let top = pageRect.height - pageOffset.bottom
            
            let context = pdfContext.cgContext
            context.saveGState()
            
            context.setFillColor(footer.colour.cgColor)
            let rectWidth = pageRect.width - (pageOffset.left + pageOffset.right)
            let rect = CGRect(x: pageOffset.left, y: top, width: rectWidth, height: 0.25)
            let path = UIBezierPath(rect: rect).cgPath
            context.addPath(path)
            context.drawPath(using: .fill)
            
            context.restoreGState()
            
            if footer.text != "" {
                let _ = pdfTextDrawer.drawWrappingText(text: footer.text,
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
        let _ = pdfTextDrawer.drawSingleLineText(text: "Page: \(footer.pageNumber)", textColour: colour, font: font, alignment: .right, top: pageRect.height - pageOffset.bottom + 7)
        footer.pageNumber += 1
    }
}
