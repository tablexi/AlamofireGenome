Pod::Spec.new do |spec|
  spec.name = "AlamofireGenome"
  spec.version = "1.0.1"
  spec.summary = "An Alamofire extension that automatically converts JSON into Swift objects using Genome"
  spec.homepage = "https://github.com/tablexi/AlamofireGenome"
  spec.license = { type: "MIT", file: "LICENSE" }
  spec.authors = {
    "Dan Hodos" => "danhodos@gmail.com",
    "John Dzak" => "john.dzak@gmail.com",
  }
  spec.platform = :ios, "8.0"
  spec.requires_arc = true
  spec.source = { git: "#{spec.homepage}.git", tag: "v#{spec.version}", submodules: true }
  spec.source_files = "AlamofireGenome/**/*.{h,swift}"

  spec.dependency "Alamofire", "~> 3.0"
  spec.dependency "Genome", "~> 1.0"
end
