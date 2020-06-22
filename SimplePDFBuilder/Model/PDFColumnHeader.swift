//
//  PDFHeader.swift
//  PaymentsPDF
//
//  Created by Maksim on 17/06/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import Foundation

/// This is used for PDF Table creation as a header of the table
public struct PDFColumnHeader {
    /// Column name text
    let text: String
    
    /// Alignment of the column
    let alignment: Alignment
    
    /// Weight of the column in comparison with others
    ///
    /// Example: If the weight of the columns would be 1:2:1
    /// then middle column will twice of size of the other two
    let weight: Int
    
    
    public init (name: String, alignment: Alignment = .left, weight: Int = 1) {
        self.text = name
        self.alignment = alignment
        self.weight = weight
    }
}
