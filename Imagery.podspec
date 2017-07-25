Pod::Spec.new do |s|
  s.name         = "Imagery"
  s.version      = "1.1.0"
  s.summary      = "A lightweight library for downloading and cacheing image from the web."
  s.homepage     = "https://meniny.cn/"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.authors            = { "Elias Abel" => "meniny@qq.com" }
  s.social_media_url   = "https://meniny.cn"

  s.ios.deployment_target = "8.0"
  s.tvos.deployment_target = "9.0"
  s.osx.deployment_target = "10.10"
  s.watchos.deployment_target = "2.0"

  s.source       = { :git => "https://github.com/Meniny/Imagery.git", :tag => s.version }

  s.source_files  = ["Imagery/*.swift", "Imagery/Imagery.h", "Imagery/Imagery.swift"]
  s.public_header_files = ["Imagery/Imagery.h"]

  s.osx.exclude_files = ["Imagery/AnimatedImageView.swift",
                        "Imagery/UIButton+Imagery.swift"]
  s.watchos.exclude_files = ["Imagery/AnimatedImageView.swift",
                            "Imagery/UIButton+Imagery.swift",
                            "Imagery/ImageView+Imagery.swift",
                            "Imagery/NSButton+Imagery.swift",
                            "Imagery/Indicator.swift",
                            "Imagery/Filter.swift"]
  s.ios.exclude_files = "Imagery/NSButton+Imagery.swift"
  s.tvos.exclude_files = "Imagery/NSButton+Imagery.swift"

  s.requires_arc = true

  s.framework = 'Foundation', "CFNetwork", 'ImageIO', 'CoreGraphics', 'Accelerate', 'CoreImage'

  s.pod_target_xcconfig = {
                          'SWIFT_VERSION' => '3.0'
                          }
end
