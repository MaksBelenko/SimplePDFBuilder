//
//  PDFTextDrawer.swift
//  PaymentsPDF
//
//  Created by Maksim on 19/06/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit.UIGraphicsImageRenderer

internal final class PDFTextDrawer {
    
    private let pdfContext: UIGraphicsPDFRendererContext
    private let pageRect: CGRect
    
    // TODO: Update with the value of pageOffset in PDFBuilder
    var pageMargins: PDFMargins
    
    
    
    // MARK: - Deinit
    
    deinit {
        print("DEBUG: PDFTextDrawer deinit is called")
    }
    
    
    
    // MARK: - Initialisation
    init(_ pageData: PageData) {
        pdfContext = pageData.pdfContext
        pageRect = pageData.pageRect
        pageMargins = pageData.pageMargins
    }
    
    
    // MARK: - Public methods
    
    /**
     Draws text depending n the size of the string as either single line or multi line
     */
    func drawText(text: String, font: UIFont, color: UIColor, lineSpacing: CGFloat = 0, alignment: Alignment,  top: CGFloat) -> CGFloat {
        let pageWidth = pageRect.width - (pageMargins.left + pageMargins.right)
        let textWidth = textSizeChecker(text: text, font: font)
        
        let bottom: CGFloat
        
        if (pageWidth > textWidth) {
            bottom = drawSingleLineText(text: text, font: font, alignment: alignment, top: top)
        } else {
            bottom = drawWrappingText(text: text, font: font, lineSpacing: lineSpacing, alignment: alignment.nsTextAlignment(), top: top)
        }
        
        return bottom
    }
    
    
    
    /**
     Use to add a single line of text with alignment in the page
     - Parameter text: Text that should be presented
     - Parameter textColour: Colour of the text (Default is black)
     - Parameter font: Font of the text (Default is tableRowsFont property)
     - Parameter pageRect: Page size rectangle
     - Parameter alignment: Enum to show the alignment of the text relative to the page
     - Parameter top: Top Offset
     */
    private func drawSingleLineText(text: String, textColour: UIColor = .black, font: UIFont, alignment: Alignment, top: CGFloat) -> CGFloat {
        let textAttributes = [NSAttributedString.Key.foregroundColor : textColour, NSAttributedString.Key.font: font]
        let attributedText = NSAttributedString(string: text, attributes: textAttributes)
        let textStringSize = attributedText.size()

        let textX = getAlignedPositionX(alignment: alignment, pageRect: pageRect, width: textStringSize.width)
        let textStringRect = CGRect(x: textX, y: top, width: textStringSize.width, height: textStringSize.height)

        attributedText.draw(in: textStringRect)

        return textStringRect.origin.y + textStringRect.size.height
    }
    
    
    
    
    
    /**
     Use to add text that is long and therefore might be wrapped
     - Parameter text: Text that should be presented
     - Parameter font: Font of the text to be shown
     - Parameter lineSpacing: Spacing between the lines
     - Parameter alignment: Alignment of the text
     - Parameter top: Top Offset
     */
    private func drawWrappingText(text: String, font: UIFont, color: UIColor = .black, lineSpacing: CGFloat, alignment: NSTextAlignment,  top: CGFloat) -> CGFloat {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .natural
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.alignment = alignment
        
        let textAttributes = [ NSAttributedString.Key.paragraphStyle: paragraphStyle,
                               NSAttributedString.Key.font: font,
                               NSAttributedString.Key.foregroundColor: color]

        let attributedText = NSAttributedString(string: text, attributes: textAttributes)
        
        let textWidth = pageRect.width - (pageMargins.left + pageMargins.right)
        var boundsRect = attributedText.boundingRect(with: CGSize(width: textWidth, height: 0),
                                    options: .usesLineFragmentOrigin,
                                    context: .none)
        
        boundsRect.origin = CGPoint(x: pageMargins.left, y: top)
        
        attributedText.draw(in: boundsRect)
      
        return top + boundsRect.height
    }
    

    
    
    // MARK: - Helpers
    
    /**
     Helper method to get X-Coordinate offset
     - Parameter alignment: Enum to show the alignment of the image relative to the page
     - Parameter pageRect: Page size rectangle
     - Parameter width: Width of the image
     */
    private func getAlignedPositionX(alignment: Alignment, pageRect: CGRect, width: CGFloat) -> CGFloat {
        switch alignment
        {
        case .left:
            return pageMargins.left
        case .centre:
            return (pageRect.width - width) / 2.0
        case .right:
            return pageRect.width - width - pageMargins.right
        }
    }
    
    
    /**
     
     */
    private func textSizeChecker(text: String, font: UIFont) -> CGFloat {
        let attributedText = NSAttributedString(string: text,
                                                attributes: [NSAttributedString.Key.font: font])
        return attributedText.size().width
    }
}
