//
//  PDFFooter.swift
//  SimplePDFBuilder
//
//  Created by Maksim on 22/06/2020.
//  Copyright © 2020 Maksim Belenko. All rights reserved.
//

import UIKit.UIColor

internal struct PDFFooter {
    var isEnabled: Bool
    var pagingEnabled: Bool
    var text: String
    var colour: UIColor
    var pageNumber: Int = 1
}
