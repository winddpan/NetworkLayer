Pod::Spec.new do |spec|
  spec.name         = "NetworkLayer"
  spec.version      = "1.0.0"
  spec.summary      = "NetworkLayer"
  spec.description  = <<-DESC
  No description
  DESC
  spec.homepage     = "https://gitlab.kaiqi.xin"
  spec.license      = "MIT"
  spec.platform = :ios, '13.0' 
  spec.swift_version = '5.5'

  spec.author       = { "PAN" => "panxiaoping@yonrun.com" }
  spec.source       = { :git => "https://none.com" }
  spec.source_files  = "**/*.{swift,h,m}"
  spec.exclude_files = ['Development/**/*']
end
