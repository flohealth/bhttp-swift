# Swift implementation of Binary HTTP 


<a href="LICENSE.txt">
    <img src="https://img.shields.io/badge/license-MIT-brightgreen.svg" alt="MIT License">
</a>
<a href="https://github.com/apple/swift-package-manager" alt="RxSwift on Swift Package Manager" title="RxSwift on Swift Package Manager">
    <img src="https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg" />
</a>


## Description
This project is a Swift language implementation of the Binary HTTP format, according to [RFC9292 "Binary Representation of HTTP Messages"](https://datatracker.ietf.org/doc/rfc9292/). It allows serializing Apple `Foundation` types such as `URLRequest` and `HTTPURLResponse` into binary data and back from it. This allows for encoding HTTP messages that can be conveyed outside of the HTTP protocol, for example, to use in [Oblivious HTTP](https://datatracker.ietf.org/doc/draft-ietf-ohai-ohttp/).


## Table of Contents
- [Installation](#installation)
- [Usage](#usage)
- [Limitations](#limitations)


## Installation


#### Swift Package Manager


You can use [The Swift Package Manager](https://swift.org/package-manager) to install `BHTTPSwift` by adding the dependency to your `Package.swift` file:


```swift
// swift-tools-version:4.0
import PackageDescription


let package = Package(
    name: "YOUR_PROJECT_NAME",
    dependencies: [
        .package(url: "git@github.com:flohealth/bhttp-swift.git", from: "0.1.0"),
    ]
)
```


## Usage


Importing the `BHTTPSwift` module allows using methods provided by extensions to `URLRequest` and `HTTPURLResponse`:


```swift
// Import the Binary HTTP library
import BHTTPSwift


// Encode URLRequest into Data
let request: URLRequest = URLRequest(...)
let requestData: Data = try request.asBinaryHTTP()


// Decode HTTPURLResponse from Data
let responseData: Data = Data(...)
let decodedResponse = try HTTPURLResponse.from(url: url, binaryHTTPData: responseData)
```


## Feature support


Binary HTTP [specification](https://datatracker.ietf.org/doc/rfc9292/) defines two formats of messages (meaning both requests and responses): _Known-Length_ Messages and _Indeterminate-Length_ Messages. Ideally, this library could support serialization and deserialization of both formats for both request and response. Current support is limited to _Known-Length_ Messages only and two possible translations that are required by client applications:


1. Serialization of `URLRequest` into Known-Length Request
2. Deserialization of `HTTPURLResponse` from Known-Length Response


#### Supported translations matrix


| Message Type                  | To Binary | From Binary |
| ----------------------------- |:---------:| :----------:|
| Known-Length Request          | supported |      X      |
| Known-Length Response         |     X     |  supported  |
| Indeterminate-Length Request  |     X     |      X      |
| Indeterminate-Length Response |     X     |      X      |


## Limitations


#### HTTP Fields encoding


This library uses ASCII to encode and decode string data for URL and HTTP header fields and their values. It does not implement automatic encoding of any non-ASCII characters into ASCII and will throw an error if it encounters any. In particular:
- If a non-ASCII character is encountered in the URL or a header field (field name or value) of an `URLRequest`, `RequestCreationError` will be thrown, indicating the point of failure
- If header data of a response cannot be decoded into String using ASCII, `BinaryHTTPDecodingError.asciiDecodingError` will be thrown

If you still need to pass non-ASCII values, encode them into ASCII **before** calling this library. For example, use percent-encoding for request URLs, etc.

## License

Released under [**MIT License**](LICENSE.txt).