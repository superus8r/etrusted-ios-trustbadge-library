Pod::Spec.new do |spec|
  spec.name         = "Trustylib"
  spec.version      = "0.1.3"
  spec.summary      = "Trustylib library for the iOS platform"
  spec.description  = <<-DESC
  Trustylib iOS library provides UI widgets for displaying trustmark logo and shop reviews in iOS applications. It provides an easy integration for these widgets with very little amount of code, please see the readme section for more details.
                   DESC

  spec.homepage     = "https://github.com/trustedshops-public/etrusted-ios-trustbadge-library"
  spec.license      = "MIT"
  spec.author       = { "Trusted Shops GmbH" => "https://www.trustedshops.com/" }

  spec.platform     = :ios, "13.0"
  spec.swift_versions = "5.3"
  spec.source = { :git => "https://github.com/trustedshops-public/etrusted-ios-trustbadge-library.git", :tag => "#{spec.version}"}
  #spec.source_files = "Sources/Trustylib/**/*.{swift}"
  spec.resources = "Sources/Trustylib/Resources/Images/*.png"
end