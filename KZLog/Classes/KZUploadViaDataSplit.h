//
//  KZUploadViaDataSplit.h
//  KZQiNiuObjectStore
//
//  Created by Khazan on 2021/3/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KZUploadViaDataSplit : NSObject

# pragma mark - splite data and upload subdata - big memory use

- (void)spliteDataAndUploadWithData:(NSData *)data
                          chunkSize:(NSUInteger)chunkSize
                           fileName:(NSString *)fileName
                               host:(NSString *)host
                             bucket:(NSString *)bucket
                          accessKey:(NSString *)accessKey
                          secretKey:(NSString *)secretKey
                            success:(void (^)(void))success
                            failure:(void (^)(void))failure;


# pragma mark - splite data and upload subdata - little memory use

- (void)spliteDataAndUploadWithFilePath:(NSString *)filePath
                              chunkSize:(NSUInteger)chunkSize
                               fileName:(NSString *)fileName
                                   host:(NSString *)host
                                 bucket:(NSString *)bucket
                              accessKey:(NSString *)accessKey
                              secretKey:(NSString *)secretKey
                                success:(void (^)(void))success
                                failure:(void (^)(void))failure;


@end

NS_ASSUME_NONNULL_END
