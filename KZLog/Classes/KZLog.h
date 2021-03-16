//
//  KZLog.h
//  Pods-KZLog_Example
//
//  Created by Khazan on 2021/3/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KZLog : NSObject

+ (KZLog *)sharedInstance;

# pragma mark - sync all log files to QiNiu cloud

- (void)syncAllLogsToQiNiuWithHost:(NSString *)host
                            bucket:(NSString *)bucket
                         accessKey:(NSString *)accessKey
                         secretKey:(NSString *)secretKey;

@end

NS_ASSUME_NONNULL_END
