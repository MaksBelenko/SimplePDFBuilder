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
            pageMargins = pdfHelper.marginsLookup(forMargins: paperMargins)
            pdfTextDrawer?.pageMargins = pageMargins
            pdfTableDrawer?.pageMargins = pageMargins
            pdfImageDrawer?.pageMargins = pageMargins
            pdfFooterDrawer?.pageMargins = pageMargins
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
    private var pageMargins = PDFMargins(top: 72, left: 72, right: 72, bottom: 72) //Inch each
    /// Current font
    private var currentFont = UIFont.systemFont(ofSize: 12)

    /// Accumulates all the actions for PDF builder
    private let pdfActions = PDFActions()

    /// offset in the PDF
    private lazy var yOffset: CGFloat = pageMargins.top
    /// Holds temprorary offset in case release of line happens
    private var holdTmpYOffset: CGFloat = 0
    
    /// Getter and Setter for yOffset
    private var currentYOffset: CGFloat {
        get { return yOffset }
        set {
            if (holdOffset == false) {
                yOffset = newValue
            }
            holdTmpYOffset = newValue
        }
    }
    
    /// Used to determine weather pdf page offset should or shouldn't change
    private var holdOffset = false
    
    /// PDF Paper size rectangle
    private var pageRect: CGRect!
    /// PDF renderer context
    private var pdfContext: UIGraphicsPDFRendererContext!

    private let pdfHelper = PDFHelpers()
    private var pdfTextDrawer: PDFTextDrawer?
    private var pdfFooterDrawer: PDFFooterDrawer?
    private var pdfTableDrawer: PDFTableDrawer?
    private var pdfImageDrawer: PDFImageDrawer?

        
    
    
    
    
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
            
            initialiseObjects()
            
            context.beginPage() //new page
            self.pdfActions.generatePDF()
            
            pdfFooterDrawer?.drawFooterIfNeeded()
        }

        pdfTableDrawer?.releaseFuncReferences()
        
        return data
    }
    
    
    
    /**
     Initialise all objects to be used
     */
    private func initialiseObjects() {
        let pageData = PageData(pdfContext: pdfContext, pageRect: pageRect, pageMargins: pageMargins)
        
        pdfTextDrawer = PDFTextDrawer(pageData)
        pdfTableDrawer = PDFTableDrawer(pageData, startNewPage: self.startNewPDFPage)
        pdfImageDrawer = PDFImageDrawer(pageData)
        pdfFooterDrawer = PDFFooterDrawer(pageData)
    }

    
    // MARK: - Public methods
    
    
    /**
     Allows to hold PDF line offset, therefore next objects will be drawn on the same line
     
     If you will set for PDF to hold the line, it means that all the next objects (text, images, etc.., except "addSpace")
     will be drawn on the same line as the object before "holdPDFLine" method was executed
     */
    @discardableResult
    public func holdLine() -> PDFBuilder {
        pdfActions.addAction { [unowned self] in
            self.holdOffset = true
        }
        
        return self
    }
    
    
    /**
     Releases the holding of the line in PDF (read summary of "holdPDFLine" method to understand better)
     */
    @discardableResult
    public func releaseLine() -> PDFBuilder {
        pdfActions.addAction { [unowned self] in
            self.holdOffset = false
            self.currentYOffset = self.holdTmpYOffset
        }
        
        return self
    }
    
    
    
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
     Change paper margins for the next elements you will be adding
     - Parameter margins: Paper margin type
     */
    @discardableResult
    public func changePaperMargins(to margins: PaperMargins) -> PDFBuilder {
        pdfActions.addAction { [unowned self] in
            self.paperMargins = margins
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
    public func addText(text: String, alignment: Alignment, font: UIFont = .systemFont(ofSize: 11), colour: UIColor = .black) -> PDFBuilder  {
        pdfActions.addAction { [unowned self] in
            self.currentYOffset = self.checkOffset(forFont: font, offset: self.currentYOffset)
            guard let drawer = self.pdfTextDrawer else { return }
            let spacing = self.lineSpacing * self.getCurrentFontHeight(forFont: font)
            self.currentYOffset = drawer.drawText(text: text, font: font, color: colour, lineSpacing: spacing, alignment: alignment, top: self.currentYOffset)

            self.holdTmpYOffset = self.checkOffset(forFont: self.currentFont, offset: self.holdTmpYOffset)
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
            guard let drawer = self.pdfImageDrawer else { return }
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
    public func addTable(headers: [PDFColumnHeader], rows: [PDFTableRow], tableType: TableType = .Modern, font: UIFont = .systemFont(ofSize: 11), tableColour: UIColor = .darkGray) throws -> PDFBuilder {
        try validate(headers, rows)
        
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
            self.currentYOffset = self.pageMargins.top
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
        let attributedText = NSAttributedString(string: "ooooo", attributes: textAttributes)
        return attributedText.size().height
    }
    
    
    private func checkOffset(forFont font: UIFont, offset: CGFloat) -> CGFloat {
        if (offset != pageMargins.top) {
            return offset + lineSpacing * getCurrentFontHeight(forFont: font)
        }
        return offset
    }

    
    
    // MARK: - Validation
        private func validate(_ headers: [PDFColumnHeader], _ rows: [PDFTableRow]) throws {
            for row in rows {
                guard headers.count >= row.count() else {
                    throw PDFTableError.notEnoughHeaders
                }
            }
        }
    
}
