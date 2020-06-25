//
//  PDFImageDrawer.swift
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
