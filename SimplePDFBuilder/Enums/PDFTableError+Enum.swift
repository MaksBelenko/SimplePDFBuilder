//
//  TableError.swift
//  SimplePDFBuilder
//
//  Created by Maksim on 24/06/2020.
//  Copyright © 2020 Maksim Belenko. All rights reserved.
//

enum PDFTableError: Error {
    case notEnoughHeaders
}

extension PDFTableError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .notEnoughHeaders:
            return NSLocalizedString("ERROR creating PDF Table: Number of column headers should be greater than number of entries in the PDFTableRow", comment: "")
        }
    }
}
