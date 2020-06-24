//
//  PageData.swift
//  SimplePDFBuilder
//
//  Created by Maksim on 24/06/2020.
//  Copyright © 2020 Maksim Belenko. All rights reserved.
//

import UIKit.UIGraphicsImageRenderer
import CoreGraphics

internal struct PageData {
    let pdfContext: UIGraphicsPDFRendererContext
    let pageRect: CGRect
    let pageMargins: PDFMargins
}
