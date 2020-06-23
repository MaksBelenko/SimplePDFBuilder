//
//  PDFCreator.swift
//  PaymentsPDF
//
//  Created by Maksim on 04/04/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit
import PDFKit

public final class PDFBuilder {

    // MARK: - Public fields
    
    /// Name of the creator in PDF Metadata
    public var metaCreator: String = "Unknown"
    /// Name of the author in PDF Metadata
    public var metaAuthor: String = "Unknown"
    /// Name of the title in PDF Metadata
    public var metaTitle: String = "Unknown Title"

    /// Paper size (Default is .A4)
    public var paperSize: PaperSize = .A4
    /// Paper orientation (Deafult is .Portrait)
    public var paperOrientation: PaperOrientation = .Portrait
    /// Paper margins type (Default is .Normal)
    public var paperMargins: PaperMargins = .Normal {
        didSet {
            pageOffset = pdfHelper.marginsLookup(forMargins: paperMargins)
            pdfTextDrawer?.pageOffset = pageOffset
            pdfTableDrawer?.pageOffset = pageOffset
            pdfFooterDrawer?.pageOffset = pageOffset
        }
    }

    /// Spacing of the document (Default is 1.08)
    public var lineSpacing: CGFloat = 1.08 { // Word default spacing
        didSet {
            if (lineSpacing < 0) {
                lineSpacing = 0
            }
        }
    }
    
    
    // MARK: - Private fields
    
    // Page margins containing top, left, right and bottom margins
    private var pageOffset = PDFMargins(top: 72, left: 72, right: 72, bottom: 72) //Inch each
    /// Current font
    private var currentFont = UIFont.systemFont(ofSize: 12)

    /// Accumulates all the actions for PDF builder
    private let pdfActions = PDFActions()

    /// offset in the PDF
    private lazy var currentYOffset: CGFloat = pageOffset.top
    /// PDF Paper size rectangle
    private var pageRect: CGRect!
    /// PDF renderer context
    private var pdfContext: UIGraphicsPDFRendererContext!

    private let pdfHelper = PDFHelpers()
    private var pdfTextDrawer: PDFTextDrawer?
    private var pdfFooterDrawer: PDFFooterDrawer?
    private var pdfTableDrawer: PDFTableDrawer?

        
    
    
    
    
    // MARK: - Deinit
    
    deinit {
        #if DEBUG
            print("DEBUG: PDFBuilder deinit is called")
        #endif
    }
    
    
    // MARK: - Initalisation
    
    public init() {
        
    }
    
    
    //MARK: - PDF Creation

    /**
    Creates PDF file data
    */
    public func build() -> Data {
        let pdfMetaData = [ kCGPDFContextCreator: metaCreator,
                            kCGPDFContextAuthor:  metaAuthor,
                            kCGPDFContextTitle:   metaTitle ]

        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        pageRect = pdfHelper.paperLookup(forSize: paperSize, orientation: paperOrientation)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)

        let data = renderer.pdfData { [unowned self] (context) in
            self.pdfContext = context
            
            self.pdfTextDrawer = PDFTextDrawer(context: self.pdfContext, pageRect: self.pageRect)
            self.pdfTableDrawer = PDFTableDrawer(context: self.pdfContext, pageRect: self.pageRect, startNewPage: self.startNewPDFPage)
            self.pdfFooterDrawer = PDFFooterDrawer(context: self.pdfContext, pageRect: self.pageRect)
            
            context.beginPage() //new page
            self.pdfActions.generatePDF()
            
            pdfFooterDrawer?.drawFooterIfNeeded()
        }

        pdfTableDrawer?.releaseFuncReferences()
        
        return data
    }

    
    // MARK: - Public methods
    
    /**
     Add space from previous object in the PDF
     - Parameter height: Height of the space in inches (= 2.54cm)
     */
    @discardableResult
    public func addSpace(inches: CGFloat) -> PDFBuilder {
        pdfActions.addAction { [unowned self] in
            let height = inches * 72
            self.currentYOffset += height
        }
        
        return self
    }
    
    
    /**
     Add space from previous object in the PDF
     - Parameter height: Height of the space in centimetres
     */
    @discardableResult
    public func addSpace(centimeters: CGFloat) -> PDFBuilder {
        pdfActions.addAction { [unowned self] in
            let height = centimeters * 2.54 * 72
            self.currentYOffset += height
        }
        
        return self
    }
    
    /**
     Adds single line of text to PDF
     - Parameter text: Text to add
     - Parameter alignment: Alignment of the text
     - Parameter font: Font of the text ( Default is .systemFont(ofSize: 12) )
     */
    @discardableResult
    public func addSingleLine(text: String, alignment: Alignment, font: UIFont = .systemFont(ofSize: 11), colour: UIColor = .black) -> PDFBuilder  {
        pdfActions.addAction { [unowned self] in
            self.checkOffset(forFont: font)
            guard let drawer = self.pdfTextDrawer else { return }
            self.currentYOffset = drawer.drawSingleLineText(text: text, textColour: colour, font: font, alignment: alignment, top: self.currentYOffset)
        }
        
        return self
    }
    
    /**
    Adds multiple lines of text to PDF
     
     Use when you are writing a paragraph
    - Parameter text: Text to be added
    - Parameter alignment: Alignment of the text
    - Parameter font: Font of the text ( Default is .systemFont(ofSize: 12) )
    */
    @discardableResult
    public func addMultiLineText(text: String, alignment: NSTextAlignment = .left, font: UIFont = .systemFont(ofSize: 12)) -> PDFBuilder {
        pdfActions.addAction { [unowned self] in
            self.checkOffset(forFont: font)
            let spacing = self.lineSpacing * self.getCurrentFontHeight(forFont: font)
            
            guard let drawer = self.pdfTextDrawer else { return }
            self.currentYOffset = drawer.drawWrappingText(text: text, font: font, lineSpacing: spacing, alignment: alignment, top: self.currentYOffset)
        }
        
        return self
    }

    /**
     Add image to PDF
     - Parameter image: Image to be added
     - Parameter maxWidth: Width of the image in points (72 points is 1 inch (2.54 cm) )
     - Parameter alignment: Alignment of the text
     */
    @discardableResult
    public func addImage(image: UIImage, maxWidth: CGFloat, alignment: Alignment) -> PDFBuilder {
        pdfActions.addAction { [unowned self] in
            guard let drawer = self.pdfTextDrawer else { return }
            self.currentYOffset = drawer.drawImage(image: image, width: maxWidth, alignment: alignment, imageTop: self.currentYOffset)
        }
        
        return self
    }
    
    
    /**
     Adds footer to the pages starting from the current one
     
     Example: If you have a cover page then after starting new page and adding this method
              the footer will go to the rest of the pages but not on the cover page
     - Parameter pagingEnabled: Put as true if you want to number the pages at the bottom right corner
     - Parameter text: Text to be shown in the footer (use \n in the text if you want multiple lines)
     - Parameter colour: Colour of the footer
     */
    @discardableResult
    public func addFooter(pagingEnabled: Bool, text: String = "", colour: UIColor = UIColor.black.withAlphaComponent(0.5)) -> PDFBuilder {
        pdfActions.addAction { [unowned self] in
            guard let drawer = self.pdfFooterDrawer else { return }
            drawer.footer.isEnabled = true
            drawer.footer.pagingEnabled = pagingEnabled
            drawer.footer.text = text
            drawer.footer.colour = colour
        }
        
        return self
    }
    
    /**
     Adds table to the PDF
     - Parameter headers: Header details including text, alignment of the column and the weight in comparison with other columns
     - Parameter rows: Table rows with the data
     - Parameter font: Font of the table text (headers and rows) ( Default is .systemFont(ofSize: 11) )
     - Parameter tableColour: Table colour theme ( Default is .darkGray )
     */
    @discardableResult
    public func addTable(headers: [PDFColumnHeader], rows: [PDFTableRow], tableType: TableType = .Modern, font: UIFont = .systemFont(ofSize: 11), tableColour: UIColor = .darkGray) -> PDFBuilder {
        pdfActions.addAction { [unowned self] in
            //TODO: Remove startnewpage and add footer method
            guard let drawer = self.pdfTableDrawer else { return }
            drawer.changeTableType(with: tableType)
            self.currentYOffset = drawer.drawTable(headers: headers, rows: rows, font: font, themeColour: tableColour, top: self.currentYOffset)
        }
        
        return self
    }
    
    
    /**
     Start a new PDF page
     */
    @discardableResult
    public func newPage() -> PDFBuilder {
        pdfActions.addAction { [unowned self] in
            self.currentYOffset = self.pageOffset.top
            self.startNewPDFPage()
        }
        
        return self
    }
    
    
    
    
    
    // MARK: - Private methods
    
    
    private func startNewPDFPage() {
        if let drawer = pdfFooterDrawer {
            drawer.drawFooterIfNeeded()
        }
        self.pdfContext.beginPage()
    }
    
    
    private func getCurrentFontHeight(forFont font: UIFont) -> CGFloat {
        let textAttributes = [NSAttributedString.Key.font: font]
        let attributedText = NSAttributedString(string: "Test String", attributes: textAttributes)
        return attributedText.size().height
    }
    
    
    private func checkOffset(forFont font: UIFont) {
        currentFont = font
        if (currentYOffset != pageOffset.top) {
            currentYOffset += lineSpacing * getCurrentFontHeight(forFont: font)
        }
    }

}
