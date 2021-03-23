//
//  KZUploadToken.m
//  KZQiNiuObjectStore
//
//  Created by Khazan on 2021/3/15.
//

#import "KZUploadToken.h"
#import <CommonCrypto/CommonHMAC.h>
#import "KZLogConstants.h"

@implementation KZUploadToken

+ (NSString *)tokenWithBucket:(NSString *)bucket
                     fileName:(NSString *)fileName
                    accessKey:(NSString *)accessKey
                    secretKey:(NSString *)secretKey {
    
    KZUploadToken *uploadToken = [[KZUploadToken alloc] init];
    NSString *token = [uploadToken uploadTokenWithBucket:bucket fileName:fileName accessKey:accessKey secretKey:secretKey];
    
    return token;
}


# pragma mark - generate a user access token

- (NSString *)uploadTokenWithBucket:(NSString *)bucket
                           fileName:(NSString *)fileName
                          accessKey:(NSString *)accessKey
                          secretKey:(NSString *)secretKey {
    NSDictionary *putPolicy = [self putPolicyWithBucket:bucket filename:fileName];
    NSString *encodedPutPolicy = [self urlsafe_base64_encodeWithPutPolicy:putPolicy];
    NSData *hmac = [self hmac_sha1WithEncodedPutPolicy:encodedPutPolicy secretKey:secretKey];
    NSString *encodedSign = [self urlsafe_base64_encodeWithHmac:hmac];
    NSString *uploadToken = [self uploadTokenWithAccessKey:accessKey encodedSign:encodedSign encodedPutPolicy:encodedPutPolicy];
    //    KZLOG(@"qiniu uploadToken:%@", uploadToken);
    return uploadToken;
}

- (NSDictionary *)putPolicyWithBucket:(NSString *)bucket filename:(NSString *)filename {
    NSString *scope = [NSString stringWithFormat:@"%@:%@", bucket, filename];
    NSNumber *deadline = [NSNumber numberWithUnsignedInteger:[self deadlineTime]];
    
    NSDictionary *putPolicy = @{
        @"scope": scope,
        @"deadline": deadline
    };
    
    //    KZLOG(@"putPolicy:%@", putPolicy);
    return putPolicy;
}


- (NSString *)urlsafe_base64_encodeWithPutPolicy:(NSDictionary *)putPolicy {
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:putPolicy options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        //KZLOG(@"");
    }
    NSString *base64String = [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];
    // url safe
    NSString *urlsafe_base64String = [base64String stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    urlsafe_base64String = [urlsafe_base64String stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
    
    //    KZLOG(@"urlsafe_base64_encodeWithPutPolicy \ndata:%@ \nbase64String:%@ \nresult:%@", data, base64String, urlsafe_base64String);
    return urlsafe_base64String;
}

- (NSData *)hmac_sha1WithEncodedPutPolicy:(NSString *)encodedPutPolicy secretKey:(NSString *)secretKey {
    const char *cKey  = [secretKey cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [encodedPutPolicy cStringUsingEncoding:NSUTF8StringEncoding];
    
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    return HMAC;
}

- (NSString *)urlsafe_base64_encodeWithHmac:(NSData *)hmac {
    NSString *base64String = [hmac base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    // url safe
    NSString *urlsafe_base64String = [base64String stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    urlsafe_base64String = [urlsafe_base64String stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
    //    KZLOG(@"urlsafe_base64_encodeWithSign:%@", urlsafe_base64String);
    return urlsafe_base64String;
}

- (NSString *)uploadTokenWithAccessKey:(NSString *)AccessKey encodedSign:(NSString *)encodedSign encodedPutPolicy:(NSString *)encodedPutPolicy {
    NSString *uploadToken = [NSString stringWithFormat:@"%@:%@:%@", AccessKey, encodedSign, encodedPutPolicy];
    //    KZLOG(@"uploadToken:%@", uploadToken);
    return uploadToken;
}

- (NSUInteger)deadlineTime {
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    return time + 3600;
}



@end
