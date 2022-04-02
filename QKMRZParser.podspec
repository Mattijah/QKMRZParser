Pod::Spec.new do |s|
  s.name          = "QKMRZParser"
  s.version       = "2.0.0"
  s.summary       = "Parses MRZ (Machine Readable Zone) from identity documents."
  s.author        = { "Matej Dorcak" => "sss.mado@gmail.com" }
  s.homepage      = "https://github.com/Mattijah/QKMRZParser"
  s.license       = { :type => "MIT", :file => "LICENSE" }
  s.source        = { :git => "https://github.com/Mattijah/QKMRZParser.git", :tag => "v#{s.version}" }
  s.source_files  = "QKMRZParser/**/*.{swift}"
  s.frameworks    = "Foundation"
  s.ios.deployment_target = "9.0"
  s.swift_version = "5.0"
end
