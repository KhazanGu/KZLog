//
//  KZUploadToken.h
//  KZQiNiuObjectStore
//
//  Created by Khazan on 2021/3/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KZUploadToken : NSObject

# pragma mark - generate a user access token

+ (NSString *)tokenWithBucket:(NSString *)bucket
                     fileName:(NSString *)fileName
                    accessKey:(NSString *)accessKey
                    secretKey:(NSString *)secretKey;

@end

NS_ASSUME_NONNULL_END
