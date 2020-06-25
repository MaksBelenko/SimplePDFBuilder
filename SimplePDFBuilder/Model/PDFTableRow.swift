//
//  PDFTableRow.swift
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
