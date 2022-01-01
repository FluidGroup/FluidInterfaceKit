Pod::Spec.new do |spec|
  spec.name = "FluidInterfaceKit"
  spec.version = "0.1.0"
  spec.summary = "Components on UIKit for Fluid Interface"
  spec.description = <<-DESC
  This library provides components built on top of UIKit for Fluid Interface.
                   DESC

  spec.homepage = "https://github.com/muukii/FluidInterfaceKit"
  spec.license = "MIT"
  spec.author = { "Muukii" => "muukii.app@gmail.com" }
  spec.social_media_url = "https://twitter.com/muukii_app"

  spec.ios.deployment_target = "12.0"
  # spec.osx.deployment_target = "10.7"
  # spec.watchos.deployment_target = "2.0"
  # spec.tvos.deployment_target = "9.0"

  spec.source = { :git => "https://github.com/muukii/FluidInterfaceKit.git", :tag => "#{spec.version}" }
  spec.source_files = "FluidInterfaceKit/**/*.swift"  
  spec.framework = "UIKit"
  spec.requires_arc = true
  spec.swift_versions = ["5.3", "5.4", "5.5"]

  spec.dependency "MatchedTransition", ">= 1.1.0"
  spec.dependency "GeometryKit", ">= 1.0.0"
end
