//
//  KZLogConstants.h
//  Pods
//
//  Created by Khazan on 2021/3/15.
//

#ifndef KZLogConstants_h
#define KZLogConstants_h


#define KZ_APP_NAME [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]
#define KZ_APP_VERSION [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
#define KZ_BUILD_VERSION [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]

#define KZ_MODEL [[UIDevice currentDevice] localizedModel]
#define KZ_SYSTEM_NAME [[UIDevice currentDevice] systemName]
#define KZ_SYSTEM_VERSION [[UIDevice currentDevice] systemVersion]
#define KZ_DEVICE_NAME [[UIDevice currentDevice] name]
#define KZ_UDID [[[UIDevice currentDevice] identifierForVendor] UUIDString]


#define KZLOG(format, ...) ;
//#define KZLOG(format, ...) printf("debug >>> %s %s\n", [[[NSDate date] description] UTF8String], [[NSString stringWithFormat:(format), ##__VA_ARGS__] UTF8String]);


#endif /* KZLogConstants_h */
