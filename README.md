# AlamofireGenome

An [Alamofire](https://github.com/Alamofire/Alamofire) extension that automatically converts JSON into Swift objects using [Genome](https://github.com/LoganWright/Genome).

## Installation

### Cocoapods

Add the following to your `Podfile`:

```
pod 'AlamofireGenome'
```

### Carthage

Add the following to your `Cartfile`:

```
github "tablexi/AlamofireGenome"
```

## Usage

Let's pretend we're interested in querying the [Github API](https://developer.github.com/v3/) for repository information. To store retrieved data, we can define the following simple data structure:

```swift
struct GithubRepository {
  var name: String!
  var fullName: String!
  var description: String!
}

extension GithubRepository: BasicMappable {
  mutating func sequence(map: Map) throws {
    try name <~> map["name"]
    try fullName <~> map["full_name"]
    try description <~> map["description"]
  }
}
```

### Fetching a single object

To [fetch a single repository](https://developer.github.com/v3/repos/#get), we can use the following code:

```swift
let url = "https://api.github.com/repos/tablexi/AlamofireGenome"
Alamofire.request(.GET, url).responseObject { response: (Response<GithubRepository, NSError>) in
  switch response.result {
    case .Success(let repository): // ...
    case .Failure(let error): // ...
  }
}
```

### Fetching an array of objects

To [fetch a list of repositories](https://developer.github.com/v3/repos/#list-organization-repositories), we can use the following code:


```swift
let url = "https://api.github.com/orgs/tablexi/repos"
Alamofire.request(.GET, url).responseArray { response: (Response<[GithubRepository], NSError>) in
  switch response.result {
    case .Success(let repositories): // ...
    case .Failure(let error): // ...
  }
}
```

### Contributing

1. `git clone <repo_url>`
2. cd AlamofireGenome
3. ./bin/setup
