//
//  PDFImageDrawer.swift
//  SimplePDFBuilder
//
//  Created by Maksim on 24/06/2020.
//  Copyright © 2020 Maksim Belenko. All rights reserved.
//

import UIKit.UIGraphicsImageRenderer

internal final class PDFImageDrawer {
    
    private let pdfContext: UIGraphicsPDFRendererContext
    private let pageRect: CGRect
    
    var pageMargins: PDFMargins
    
    
    
    // MARK: - Deinit
    
//    deinit {
//        print("DEBUG: PDFImageDrawer deinit is called")
//    }
    
    
    
    // MARK: - Initialisation
    init(_ pageData: PageData) {
        pdfContext = pageData.pdfContext
        pageRect = pageData.pageRect
        pageMargins = pageData.pageMargins
    }
    
    
    
    // MARK: - Public methods
    
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
}
