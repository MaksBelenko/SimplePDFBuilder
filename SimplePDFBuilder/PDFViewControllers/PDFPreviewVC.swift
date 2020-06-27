//
//  PDFPreviewVC.swift
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

import UIKit
import PDFKit

public class PDFPreviewVC: UIViewController {
    
    private var pdfView = PDFView()
    
    private var pdfData: Data?
    private var pdfFileName: String!
    private var removeFileAfterClose: Bool!
    
    
    // MARK: - Initialisation
    
    /**
     Initialise PDF Preview ViewController
     - Parameter pdfData: PDF Data to be shown
     - Parameter pdfFileName: Name of the file to be saved if user will share it (no need to include ".pdf")
     - Parameter removeFileOnClose: If you want to share the PDF it will first save it to temprorary
                                    folder of your app. Therefore, if you dont want to keep them,
                                    it will be removed when the controller will dissapear.
     */
    public init(pdfData: Data?, pdfFileName: String = "CustomPDF", removeFileOnClose: Bool = true) {
        super.init(nibName: nil, bundle: nil)
        self.pdfData = pdfData
        self.pdfFileName = pdfFileName
        self.removeFileAfterClose = removeFileOnClose
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Deinit
    
    //    deinit {
    //        print("DEBUG: PDFPreviewVC deinit is called")
    //    }
    
    
    // MARK: - Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "PDF Preview"
        view.backgroundColor = .white
        
        setupBarButtons()
        setupPDFView()
        createPDFPreviewDocument()
        
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        if removeFileAfterClose {
            FileManager.default.removeFromTmp(file: self.pdfFileName)
        }
    }
    
    
    // MARK: - View setup
    
    func createPDFPreviewDocument() {
        if let data = pdfData {
            pdfView.document = PDFDocument(data: data)
            pdfView.autoScales = true
        }
    }
    
    
    
    func setupPDFView() {
        pdfView.backgroundColor = .white
        
        view.addSubview(pdfView)
        
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        pdfView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        pdfView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        pdfView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        pdfView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displaysPageBreaks = true
        //        pdfView.goToFirstPage()
    }
    
    
    
    
    
    //MARK: - Bar Button
    func setupBarButtons() {
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareButtonPressed))
        navigationItem.rightBarButtonItem = shareButton
    }
    
    
    @objc func shareButtonPressed() {
        let temporaryFolder = FileManager.default.temporaryDirectory
        pdfFileName = pdfFileName + ".pdf"
        let temporaryFileURL = temporaryFolder.appendingPathComponent(pdfFileName)
        print(temporaryFileURL.path)
        do {
            try pdfData!.write(to: temporaryFileURL) //Write document to defaults storage
            
            let activityViewController = UIActivityViewController(activityItems: [temporaryFileURL], applicationActivities: nil)
            present(activityViewController, animated: true, completion: nil)
        } catch {
            print(error)
        }
    }
    
}
