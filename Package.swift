import PackageDescription

let package = Package(
    name: "AlamofireGenome",
    dependencies: [
        .Package(url: "https://github.com/Alamofire/Alamofire.git", versions: Version(3,0,0)..<Version(4,0,0)),
        .Package(url: "https://github.com/LoganWright/Genome.git", versions: Version(1,0,0)..<Version(2,0,0)),
    ]
)
