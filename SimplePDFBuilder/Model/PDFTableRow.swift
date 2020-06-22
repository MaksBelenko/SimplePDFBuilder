//
//  PDFTableRow.swift
//  PaymentsPDF
//
//  Created by Maksim on 17/06/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import Foundation

/// This is used to create rows of data for the table
public struct PDFTableRow {
    /// Table row entries
    private(set) var entries: [String] = []
    /// count that is used for Sequence and IteratorProtocol conformance
    private var current = 0
    
    public init(_ entries: [String] ) {
        for e in entries {
            self.entries.append(e)
        }
    }
    
    /// Gets the count of all entries
    func count() -> Int {
        return entries.count
    }
}


extension PDFTableRow: Sequence, IteratorProtocol {
    public mutating func next() -> String? {
        if current == entries.count {
            return nil
        } else {
            defer { current += 1}
            return entries[current]
        }
    }
}
