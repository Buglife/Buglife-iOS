Pod::Spec.new do |s|
  s.name                  = "Buglife"
  s.version               = "1.3.2"
  s.summary               = "Awesome bug reporting 😎"
  s.description           = "Report bugs, annotate screenshots, and collect logs from within your iOS app!"
  s.homepage              = "http://www.buglife.com"
  s.license               = { "type" => "Commercial", "text" => "See http://www.buglife.com/terms-of-service"}
  s.author                = { "Buglife" => "support@buglife.com" }
  s.source                = { "git" => "https://github.com/Buglife/Buglife-iOS.git", :tag => s.version.to_s }
  s.platform              = :ios, '7.0'
  s.preserve_paths        = [ "Buglife.framework/*" ]
  s.source_files          = "Buglife.framework/Versions/A/Headers/*.{h}"
  s.public_header_files   = "Buglife.framework/Versions/A/Headers/*.{h}"
  s.vendored_frameworks   = "Buglife.framework"
  s.frameworks            = ["CoreTelephony", "SystemConfiguration"]
end
