//
//  PDFActions.swift
//  PaymentsPDF
//
//  Created by Maksim on 19/06/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import Foundation

internal final class PDFActions {
    
    /// Actions to be executed on PDF generation
    private var pdfActions: Array<() -> ()> = []
    
    
    // MARK: - Deinit
    
    deinit {
        print("DEBUG: PDFActions deinit is called")
    }
    
    
    // MARK: - Public methods
    
    /**
     Queues all actions
     - Parameter method: Method that should be queued
     */
    func addAction(method: @escaping () -> ()) {
           pdfActions.append(method)
    }
    
    /**
     Executes all queued actions
     */
    func generatePDF() {
        for action in pdfActions {
            action()
        }
    }
}
