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
    var pageOffset = PDFMargins(top: 72, left: 72, right: 72, bottom: 72)
    
    
    
    // MARK: - Deinit
    
    deinit {
        print("DEBUG: PDFTextDrawer deinit is called")
    }
    
    
    
    // MARK: - Initialisation
    init(context: UIGraphicsPDFRendererContext, pageRect: CGRect) {
        pdfContext = context
        self.pageRect = pageRect
    }
    
    
    // MARK: - Public methods
    
    /**
     Use to add a single line of text with alignment in the page
     - Parameter text: Text that should be presented
     - Parameter textColour: Colour of the text (Default is black)
     - Parameter font: Font of the text (Default is tableRowsFont property)
     - Parameter pageRect: Page size rectangle
     - Parameter alignment: Enum to show the alignment of the text relative to the page
     - Parameter top: Top Offset
     */
    func drawSingleLineText(text: String, textColour: UIColor = .black, font: UIFont, alignment: Alignment, top: CGFloat) -> CGFloat {
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
    func drawWrappingText(text: String, font: UIFont, color: UIColor = .black, lineSpacing: CGFloat, alignment: NSTextAlignment,  top: CGFloat) -> CGFloat {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .natural
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.alignment = alignment
        
        let textAttributes = [ NSAttributedString.Key.paragraphStyle: paragraphStyle,
                               NSAttributedString.Key.font: font,
                               NSAttributedString.Key.foregroundColor: color]

        let attributedText = NSAttributedString(string: text, attributes: textAttributes)
        
        let textWidth = pageRect.width - (pageOffset.left + pageOffset.right)
        var boundsRect = attributedText.boundingRect(with: CGSize(width: textWidth, height: 0),
                                    options: .usesLineFragmentOrigin,
                                    context: .none)
        
        boundsRect.origin = CGPoint(x: pageOffset.left, y: top)
        
        attributedText.draw(in: boundsRect)
      
        return top + boundsRect.height
    }
    
    
    
    
    
    //MARK: - Image Drawing
    
    /**
    Draws and image to the PDF
    - Parameter image: UIImage to be drawn
    - Parameter imageTop: Top Offset
    - Parameter width: Width that the image should be
    - Parameter alignment: Enum to show the alignment of the image relative to the page
    */
    func drawImage(image: UIImage, width: CGFloat, alignment: Alignment, imageTop: CGFloat) -> CGFloat {
        let maxHeight = pageRect.height
        let maxWidth = (width > pageRect.width) ? pageRect.width : width

        let aspectWidth = maxWidth / image.size.width
        let aspectHeight = maxHeight / image.size.height
        let aspectRatio = min(aspectWidth, aspectHeight)

        let scaledWidth = image.size.width * aspectRatio
        let scaledHeight = image.size.height * aspectRatio
        
        let imageX = getAlignedPositionX(alignment: alignment, pageRect: pageRect, width: scaledWidth)
        let imageRect = CGRect(x: imageX, y: imageTop, width: scaledWidth, height: scaledHeight)

        image.draw(in: imageRect)
        return imageRect.origin.y + imageRect.size.height
    }

    
    
    
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
            return pageOffset.left
        case .centre:
            return (pageRect.width - width) / 2.0
        case .right:
            return pageRect.width - width - pageOffset.right
        }
    }
}
