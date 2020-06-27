
Pod::Spec.new do |spec|

  spec.name         = "SimplePDFBuilder"
  spec.version      = "1.0.0"
  spec.summary      = "SimplePDFBuilder allows to create good looking PDF files easily."

  spec.description  = "SimplePDFBuilder is a library built on top of PDFKit and which enables you to easily create PDF files in your app. This is a customisable library that allows you to add text, images and other elements including complex tables, making the creation of PDF files very simple, with no need to draw everything from scratch."

  spec.homepage     = "https://github.com/MaksBelenko/SimplePDFBuilder"
  spec.screenshots  = "https://github.com/MaksBelenko/SimplePDFBuilder/blob/master/Docs/Images/pdfPreview.png"

  spec.license      = { :type => "MIT", :file => "LICENSE" }

  spec.author             = { "MaksBelenko" => "maksim.belenko@gmail.com" }
  spec.platform     = :ios, "13.0"

  spec.source       = { :git => "https://github.com/MaksBelenko/SimplePDFBuilder", :tag => "#{spec.version}" }

  spec.source_files = "SimplePDFBuilder"
 
  spec.swift_version = "5" 

end