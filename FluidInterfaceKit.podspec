Pod::Spec.new do |spec|
  spec.name = "FluidInterfaceKit"
  spec.version = "0.5.0"
  spec.summary = "Components on UIKit for Fluid Interface"
  spec.description = <<-DESC
  This library provides components built on top of UIKit for Fluid Interface.
                   DESC

  spec.homepage = "https://github.com/muukii/FluidInterfaceKit"
  spec.license = "MIT"
  spec.author = { "Muukii" => "muukii.app@gmail.com" }
  spec.social_media_url = "https://twitter.com/muukii_app"

  spec.ios.deployment_target = "12.0"

  spec.source = { :git => "https://github.com/muukii/FluidInterfaceKit.git", :tag => "#{spec.version}" }
  spec.source_files = "Sources/FluidInterfaceKit/**/*.swift"  
  spec.framework = "UIKit"
  spec.requires_arc = true
  spec.swift_versions = ["5.3", "5.4", "5.5", "5.6"]

  spec.default_subspecs = ["Core"]

  spec.subspec "Core" do |ss|
    ss.source_files = "Sources/FluidInterfaceKit/**/*.swift"
    ss.dependency "MatchedTransition", ">= 1.1.0"
    ss.dependency "GeometryKit", ">= 1.1.0"
    ss.dependency "ResultBuilderKit", ">= 1.2.0"
  end

  spec.subspec "RideauSupport" do |ss|
    ss.source_files = "Sources/FluidInterfaceKitRideauSupport/**/*.swift"
    ss.dependency "FluidInterfaceKit/Core"
    ss.dependency "Rideau", ">= 2.1.0"
  end
end
