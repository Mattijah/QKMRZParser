[![SwiftPackageSupport](https://img.shields.io/badge/Swift_Package_Index-red?logo=swift&logoColor=white)](https://swiftpackageindex.com/Mattijah/QKMRZParser)
[![Swift 5.0](https://img.shields.io/badge/Swift-5.0-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![Git](https://img.shields.io/badge/GitHub-Mattijah-blue.svg?style=flat)](https://github.com/Mattijah)


# QKMRZParser

Parses MRZ (Machine Readable Zone) from identity documents.

## Supported formats:

* TD1
* TD2
* TD3
* MRV-A
* MRV-B
* French ID

## Installation

QKMRZParser is available through **CocoaPods** and the **Swift Package Manager**. To install it via CocoaPods simply add the following line to your Podfile:

```ruby
pod 'QKMRZParser'
```

## Usage

```swift
import QKMRZParser

let mrzLines = [
    "P<UTOERIKSSON<<ANNA<MARIA<<<<<<<<<<<<<<<<<<<",
    "L898902C36UTO7408122F1204159ZE184226B<<<<<10"
]

let mrzParser = QKMRZParser(ocrCorrection: true)
let result = mrzParser.parse(mrzLines: mrzLines)

print(result)
```


## TODO
- [ ] Tests
- [ ] Documentation
- [ ] Support Swiss Driving License
- [x] Support French national ID
- [ ] Improve OCR correction
- [ ] Latin transliteration
- [ ] Arabic transliteration
- [ ] Cyrillic transliteration



## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details
