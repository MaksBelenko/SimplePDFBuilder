//
//  PDFFooter.swift
//  SimplePDFBuilder
//
//  Created by Maksim on 22/06/2020.
//  Copyright © 2020 Maksim Belenko. All rights reserved.
//

import UIKit.UIColor

/// PDF Footer on the pages
internal struct PDFFooter {
    /// Tells the system if footer is enabled
    var isEnabled: Bool
    /// Adds paging in the footer
    var pagingEnabled: Bool
    /// Text to be shown in the footer
    var text: String
    /// Colour of the footer and text in it
    var colour: UIColor
    /// Current page number
    var pageNumber: Int = 1
}
