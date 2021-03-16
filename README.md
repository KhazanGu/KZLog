# KZLog

[![CI Status](https://img.shields.io/travis/KhazanGu/KZLog.svg?style=flat)](https://travis-ci.org/KhazanGu/KZLog)
[![Version](https://img.shields.io/cocoapods/v/KZLog.svg?style=flat)](https://cocoapods.org/pods/KZLog)
[![License](https://img.shields.io/cocoapods/l/KZLog.svg?style=flat)](https://cocoapods.org/pods/KZLog)
[![Platform](https://img.shields.io/cocoapods/p/KZLog.svg?style=flat)](https://cocoapods.org/pods/KZLog)


## Installation

pod 'KZLog', :git => 'https://github.com/KhazanGu/KZLog.git'


```
NSString *Host = @"";
NSString *bucket = @"";
NSString *accessKey = @"";
NSString *secretKey = @"";

[[KZLog sharedInstance] syncAllLogsToQiNiuWithHost:Host
                                            bucket:bucket
                                         accessKey:accessKey
                                         secretKey:secretKey];

```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Author

Khazan Gu, Khazan@foxmail.com

## License

KZLog is available under the MIT license. See the LICENSE file for more info.
