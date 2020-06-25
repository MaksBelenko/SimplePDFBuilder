//
//  PDFHelpers.swift
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

import CoreGraphics

internal final class PDFHelpers {
 
    private let pdfPerInch: Double = 72
    
    // MARK: - Deinit
    
//    deinit {
//        print("DEBUG: PDFHelpers deinit is called")
//    }
    
    
    // MARK: - Public methods
    
    /**
     Gets the size of the rectangle for PDF page
     - Parameter size: Type of the paper of "A" standard (eg. .A4)
     - Parameter orientation: Orientation of the page (eg. .Portrait)
     - Returns: Rectangle of size for the PDF page
     */
    internal func paperLookup(forSize size: PaperSize, orientation: PaperOrientation) -> CGRect {
        var pageWidth: Double
        var pageHeight: Double
        
        switch size {
        case .A1:
            pageWidth  = 23.4
            pageHeight = 33.1
        case .A2:
            pageWidth  = 16.5
            pageHeight = 23.4
        case .A3:
            pageWidth  = 11.7
            pageHeight = 16.5
        case .A4:
            pageWidth  = 8.27      //A4 format is 8.27 inches in width
            pageHeight = 11.69    //A4 format is 11.69 inches in height
        case .A5:
            pageWidth  = 5.8
            pageHeight = 4.1
        case .A6:
            pageWidth  = 4.1
            pageHeight = 5.8
        case .A7:
            pageWidth  = 2.9
            pageHeight = 4.1
        }
        
        //Update with PDF size
        pageWidth  *= pdfPerInch
        pageHeight *= pdfPerInch
        
        if (orientation == .Album) {
            let tmp = pageWidth
            pageWidth = pageHeight
            pageHeight = tmp
        }
        
        return CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
    }
    
    
    
    /**
     Lookup for the paper margin type
     - Parameter margins: Type of margins (eg. .Wide)
     - Returns: PDFPaperMargins struct for page margins
     */
    internal func marginsLookup(forMargins margins: PaperMargins) -> PDFMargins {
        let inch = CGFloat(pdfPerInch)
        
        switch margins {
        case .Normal:
            return PDFMargins(top: inch, left: inch, right: inch, bottom: inch)
        case .Narrow:
            return PDFMargins(top: 0.5*inch, left: 0.5*inch, right: 0.5*inch, bottom: 0.5*inch)
        case .Moderate:
            return PDFMargins(top: inch, left: 0.75*inch, right: 0.75*inch, bottom: inch)
        case .Wide:
            return PDFMargins(top: inch, left: 2*inch, right: 2*inch, bottom: inch)
        }
        
    }
}
