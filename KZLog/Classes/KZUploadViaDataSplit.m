//
//  KZUploadViaDataSplit.m
//  KZQiNiuObjectStore
//
//  Created by Khazan on 2021/3/15.
//

#import "KZUploadViaDataSplit.h"
#import "KZUploadToken.h"
#import "KZLogConstants.h"

@interface KZUploadViaDataSplit ()

@property (nonatomic, strong) NSURLSession *session;

@end

@implementation KZUploadViaDataSplit

# pragma mark - split data and upload subdata - big memory use

- (void)splitDataAndUploadWithData:(NSData *)data
                         chunkSize:(NSUInteger)chunkSize
                          fileName:(NSString *)fileName
                              host:(NSString *)host
                            bucket:(NSString *)bucket
                         accessKey:(NSString *)accessKey
                         secretKey:(NSString *)secretKey
                           success:(void (^)(void))success
                           failure:(void (^)(void))failure {
    
    KZLOG(@"split Data:%.0f", data.length/1024.0/1024.0);
    
    if (data.length == 0) {
        success ? success() : nil;
        return;
    }
    
    NSString *uploadToken = [KZUploadToken tokenWithBucket:bucket
                                                  fileName:fileName
                                                 accessKey:accessKey
                                                 secretKey:secretKey];
    NSString *fileNameBase64 = [[fileName dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];
    
    [self splitDataAndUploadCreateUploadTaskWithHost:host
                                              bucket:bucket
                                           accessKey:accessKey
                                           secretKey:secretKey
                                         uploadToken:uploadToken
                                            fileName:fileName
                                      fileNameBase64:fileNameBase64
                                                data:data
                                           chunkSize:chunkSize
                                             success:success
                                             failure:failure];
}

- (void)splitDataAndUploadCreateUploadTaskWithHost:(NSString *)host
                                            bucket:(NSString *)bucket
                                         accessKey:(NSString *)accessKey
                                         secretKey:(NSString *)secretKey
                                       uploadToken:(NSString *)uploadToken
                                          fileName:(NSString *)fileName
                                    fileNameBase64:(NSString *)fileNameBase64
                                              data:(NSData *)data
                                         chunkSize:(NSUInteger)chunkSize
                                           success:(void (^)(void))success
                                           failure:(void (^)(void))failure {
    __weak typeof(self) weakSelf = self;
    
    [self createUploadTaskWithHost:host
                            bucket:bucket
                         accessKey:accessKey
                         secretKey:secretKey
                       uploadToken:(NSString *)uploadToken
                          fileName:fileName
                    fileNameBase64:fileNameBase64
                           success:^(NSDictionary *responseObject) {
        
        NSString *uploadId = [responseObject objectForKey:@"uploadId"];
        
        [weakSelf splitDataAndUploadTaskWithData:data
                                       chunkSize:chunkSize
                                            host:host
                                          bucket:bucket
                                  fileNameBase64:fileNameBase64
                                        uploadId:uploadId
                                     uploadToken:uploadToken
                                         success:success
                                         failure:failure];
        
    } failure:^(NSError *error) {
        failure ? failure() : nil;
    }];
    
}

- (void)splitDataAndUploadTaskWithData:(NSData *)data
                             chunkSize:(NSUInteger)chunkSize
                                  host:(NSString *)host
                                bucket:(NSString *)bucket
                        fileNameBase64:(NSString *)fileNameBase64
                              uploadId:(NSString *)uploadId
                           uploadToken:(NSString *)uploadToken
                               success:(void (^)(void))success
                               failure:(void (^)(void))failure {
    
    __weak typeof(self) weakSelf = self;
    
    [self splitAndUploadData:data
                   chunkSize:chunkSize
              uploadWithHost:host
                      bucket:bucket
              fileNameBase64:fileNameBase64
                    uploadId:uploadId
                 uploadToken:uploadToken
                     success:^(NSArray *parts) {
        
        [weakSelf splitDataAndUploadEndUploadTaskWithHost:host
                                                   bucket:bucket
                                           fileNameBase64:fileNameBase64
                                                 uploadId:uploadId
                                              uploadToken:uploadToken
                                                    parts:parts
                                                  success:success
                                                  failure:failure];
        
    } failure:failure];
}

- (void)splitDataAndUploadEndUploadTaskWithHost:(NSString *)host
                                         bucket:(NSString *)bucket
                                 fileNameBase64:(NSString *)fileNameBase64
                                       uploadId:(NSString *)uploadId
                                    uploadToken:(NSString *)uploadToken
                                          parts:(NSArray *)parts
                                        success:(void (^)(void))success
                                        failure:(void (^)(void))failure {
    
    [self endUploadTaskWithHost:host
                         bucket:bucket
                 fileNameBase64:fileNameBase64
                       uploadId:uploadId
                    uploadToken:uploadToken
                          parts:parts
                        success:^(NSDictionary *responseObject) {
        success ? success() : nil;
    }
                        failure:^(NSError *error) {
        failure ? failure() : nil;
    }];
}


# pragma mark - read and upload file in partial - little memory use

- (void)readAndUploadFileInPartialWithFilePath:(NSString *)filePath
                                     chunkSize:(NSUInteger)chunkSize
                                      fileName:(NSString *)fileName
                                          host:(NSString *)host
                                        bucket:(NSString *)bucket
                                     accessKey:(NSString *)accessKey
                                     secretKey:(NSString *)secretKey
                                       success:(void (^)(void))success
                                       failure:(void (^)(void))failure {
    
    unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil] fileSize];
    
    KZLOG(@"split Data:%.0f", fileSize/1024.0/1024.0);
    
    if (fileSize == 0) {
        success ? success() : nil;
        return;
    }
    
    NSString *uploadToken = [KZUploadToken tokenWithBucket:bucket
                                                  fileName:fileName
                                                 accessKey:accessKey
                                                 secretKey:secretKey];
    NSString *fileNameBase64 = [[fileName dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];
    
    
    [self readAndUploadFileInPartialCreateTaskWithHost:host
                                                bucket:bucket
                                             accessKey:accessKey
                                             secretKey:secretKey
                                           uploadToken:uploadToken
                                              fileName:fileName
                                        fileNameBase64:fileNameBase64
                                              filePath:filePath
                                             chunkSize:chunkSize
                                               success:success
                                               failure:failure];
}

- (void)readAndUploadFileInPartialCreateTaskWithHost:host
                                              bucket:bucket
                                           accessKey:accessKey
                                           secretKey:secretKey
                                         uploadToken:uploadToken
                                            fileName:fileName
                                      fileNameBase64:fileNameBase64
                                            filePath:(NSString *)filePath
                                           chunkSize:(NSUInteger)chunkSize
                                             success:(void (^)(void))success
                                             failure:(void (^)(void))failure {
    
    __weak typeof(self) weakSelf = self;
    
    [self createUploadTaskWithHost:host
                            bucket:bucket
                         accessKey:accessKey
                         secretKey:secretKey
                       uploadToken:uploadToken
                          fileName:fileName
                    fileNameBase64:fileNameBase64
                           success:^(NSDictionary *responseObject) {
        
        NSString *uploadId = [responseObject objectForKey:@"uploadId"];
        
        [weakSelf readAndUploadFileInPartialUploadTaskWithFilePath:filePath
                                                         chunkSize:chunkSize
                                                             index:0
                                                    fileNameBase64:fileNameBase64
                                                          uploadId:uploadId
                                                       uploadToken:uploadToken
                                                              host:host
                                                            bucket:bucket
                                                         accessKey:accessKey
                                                         secretKey:secretKey
                                                           success:success
                                                           failure:failure];
        
        
    } failure:^(NSError *error) {
        
        failure ? failure() : nil;
        
    }];
    
}

- (void)readAndUploadFileInPartialUploadTaskWithFilePath:(NSString *)filePath
                                               chunkSize:(NSUInteger)chunkSize
                                                   index:(NSUInteger)index
                                          fileNameBase64:fileNameBase64
                                                uploadId:uploadId
                                             uploadToken:uploadToken
                                                    host:(NSString *)host
                                                  bucket:(NSString *)bucket
                                               accessKey:(NSString *)accessKey
                                               secretKey:(NSString *)secretKey
                                                 success:(void (^)(void))success
                                                 failure:(void (^)(void))failure {
    
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:filePath];
    NSMutableArray *parts = [NSMutableArray arrayWithCapacity:0];
    __weak typeof(self) weakSelf = self;
    
    [self readAndUploadFileInPartialWithFileHandle:fileHandle
                                             parts:parts
                                         chunkSize:chunkSize
                                             index:0
                                    fileNameBase64:fileNameBase64
                                          uploadId:uploadId
                                       uploadToken:uploadToken
                                              host:host
                                            bucket:bucket
                                         accessKey:accessKey
                                         secretKey:secretKey
                                           success:^(NSArray *newParts) {
        
        [fileHandle closeFile];
        
        [weakSelf readAndUploadFileInPartialEndUploadTaskWithHost:host
                                                           bucket:bucket
                                                   fileNameBase64:fileNameBase64
                                                         uploadId:uploadId
                                                      uploadToken:uploadToken
                                                            parts:newParts
                                                          success:success
                                                          failure:failure];
    }
                                           failure:^{
        [fileHandle closeFile];
        failure ? failure() : nil;
    }];
}

- (void)readAndUploadFileInPartialEndUploadTaskWithHost:(NSString *)host
                                                 bucket:(NSString *)bucket
                                         fileNameBase64:(NSString *)fileNameBase64
                                               uploadId:(NSString *)uploadId
                                            uploadToken:(NSString *)uploadToken
                                                  parts:(NSArray *)parts
                                                success:(void (^)(void))success
                                                failure:(void (^)(void))failure {
    
    [self endUploadTaskWithHost:host
                         bucket:bucket
                 fileNameBase64:fileNameBase64
                       uploadId:uploadId
                    uploadToken:uploadToken
                          parts:parts
                        success:^(NSDictionary *responseObject) {
        success ? success() : nil;
    }
                        failure:^(NSError *error) {
        failure ? failure() : nil;
    }];
}


#pragma mark -  parts upload task

// create upload task
- (void)createUploadTaskWithHost:(NSString *)host
                          bucket:(NSString *)bucket
                       accessKey:(NSString *)accessKey
                       secretKey:(NSString *)secretKey
                     uploadToken:(NSString *)uploadToken
                        fileName:(NSString *)fileName
                  fileNameBase64:(NSString *)fileNameBase64
                         success:(void (^)(NSDictionary *responseObject))success
                         failure:(void (^)(NSError *error))failure {
    
    NSString *url = [NSString stringWithFormat:@"%@/buckets/%@/objects/%@/uploads", @"https://up-z2.qiniup.com", bucket, fileNameBase64];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    NSDictionary *parameters = @{@"BucketName": bucket};
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:nil];
    
    [request setValue:[NSString stringWithFormat:@"UpToken %@", uploadToken] forHTTPHeaderField:@"Authorization"];
    request.HTTPMethod = @"POST";
    
    //    KZLOG(@"allHTTPHeaderFields:%@", request.allHTTPHeaderFields);
    //    KZLOG(@"url: %@", request.URL);
    
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            KZLOG(@"upload failure :%@", error);
            failure ? failure(error) : nil;
        } else {
            NSError *jsonErr;
            NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonErr];
            if (jsonErr) {
                failure ? failure(error) : nil;
            } else {
                KZLOG(@"upload success: %@", responseObject);
                success ? success(responseObject) : nil;
            }
        }
    }];
    
    [task resume];
}

// upload subdata
- (void)uploadSubData:(NSData *)subData
                 host:(NSString *)host
               bucket:(NSString *)bucket
       fileNameBase64:(NSString *)fileNameBase64
                index:(NSUInteger)index
             uploadId:(NSString *)uploadId
          uploadToken:(NSString *)uploadToken
              success:(void (^)(NSDictionary *responseObject))success
              failure:(void (^)(NSError *error))failure {
    
    NSString *url = [NSString stringWithFormat:@"%@/buckets/%@/objects/%@/uploads/%@/%tu", host, bucket, fileNameBase64, uploadId, index+1];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"PUT";
    
    [request setValue:[NSString stringWithFormat:@"UpToken %@", uploadToken] forHTTPHeaderField:@"Authorization"];
    [request setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%tu", subData.length] forHTTPHeaderField:@"Content-Length"];
    
    request.HTTPBody = subData;
    
    //    KZLOG(@"allHTTPHeaderFields:%@", request.allHTTPHeaderFields);
    //    KZLOG(@"url: %@", request.URL);
    
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            KZLOG(@"upload failure :%@", error);
        } else {
            NSError *jsonErr;
            NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonErr];
            if (jsonErr) {
                failure ? failure(error) : nil;
            } else {
                KZLOG(@"upload success: %@", responseObject);
                success ? success(responseObject) : nil;
            }
        }
    }];
    
    [task resume];
}


// end upload task
- (void)endUploadTaskWithHost:(NSString *)host
                       bucket:(NSString *)bucket
               fileNameBase64:(NSString *)fileNameBase64
                     uploadId:(NSString *)uploadId
                  uploadToken:(NSString *)uploadToken
                        parts:(NSArray *)parts
                      success:(void (^)(NSDictionary *responseObject))success
                      failure:(void (^)(NSError *error))failure {
    
    NSString *url = [NSString stringWithFormat:@"%@/buckets/%@/objects/%@/uploads/%@", host, bucket, fileNameBase64, uploadId];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"POST";
    
    NSDictionary *parameters = @{@"parts": parts};
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:nil];
    
    [request setValue:[NSString stringWithFormat:@"UpToken %@", uploadToken] forHTTPHeaderField:@"Authorization"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    //    KZLOG(@"allHTTPHeaderFields:%@", request.allHTTPHeaderFields);
    //    KZLOG(@"url: %@", request.URL);
    
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            KZLOG(@"upload failure :%@", error);
        } else {
            NSError *jsonErr;
            NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonErr];
            if (jsonErr) {
                failure ? failure(error) : nil;
            } else {
                KZLOG(@"upload success: params:%@ \nres:%@", parameters, responseObject);
                success ? success(responseObject) : nil;
            }
        }
    }];
    
    [task resume];
}


#pragma mark - split data to parts and upload

- (void)splitAndUploadData:(NSData *)data
                 chunkSize:(NSUInteger)chunkSize
            uploadWithHost:(NSString *)host
                    bucket:(NSString *)bucket
            fileNameBase64:(NSString *)fileNameBase64
                  uploadId:(NSString *)uploadId
               uploadToken:(NSString *)uploadToken
                   success:(void (^)(NSArray *parts))success
                   failure:(void (^)(void))failure {
    
    NSMutableArray *uploadSuccess = [NSMutableArray arrayWithCapacity:0];
    dispatch_group_t group = dispatch_group_create();
    
    NSUInteger number = data.length / chunkSize;
    for (NSUInteger i = 0; i <= number; i++) {
        dispatch_group_enter(group);
        NSRange range = NSMakeRange(i * chunkSize, MIN(data.length - i * chunkSize, chunkSize));
        NSData *subData = [data subdataWithRange:range];
        [self uploadSubData:subData
                       host:host
                     bucket:bucket
             fileNameBase64:fileNameBase64
                      index:i
                   uploadId:uploadId
                uploadToken:uploadToken
                    success:^(NSDictionary *responseObject) {
            
            NSDictionary *part = @{@"partNumber": [NSNumber numberWithUnsignedInteger:i+1],
                                   @"etag": [responseObject objectForKey:@"etag"]
            };
            [uploadSuccess addObject:part];
            dispatch_group_leave(group);
        }
                    failure:^(NSError *error) {
            dispatch_group_leave(group);
        }];
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (number == uploadSuccess.count - 1) {
            [uploadSuccess sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                return [[obj1 objectForKey:@"partNumber"] unsignedIntegerValue] > [[obj2 objectForKey:@"partNumber"] unsignedIntegerValue];
            }];
            success ? success([uploadSuccess copy]) : nil;
        } else {
            failure ? failure() : nil;
        }
    });
}

#pragma mark - partial file read and upload in async

- (void)readAndUploadFileInPartialWithFileHandle:(NSFileHandle *)fileHandle
                                           parts:(NSMutableArray *)parts
                                       chunkSize:(NSUInteger)chunkSize
                                           index:(NSUInteger)index
                                  fileNameBase64:fileNameBase64
                                        uploadId:uploadId
                                     uploadToken:uploadToken
                                            host:(NSString *)host
                                          bucket:(NSString *)bucket
                                       accessKey:(NSString *)accessKey
                                       secretKey:(NSString *)secretKey
                                         success:(void (^)(NSArray *newParts))success
                                         failure:(void (^)(void))failure {
    
    if (index != 0) {
        [fileHandle seekToFileOffset:index * chunkSize];
    }
    NSData *data = [fileHandle readDataOfLength:chunkSize];
    
    if (data == nil || data.length == 0) {
        success ? success([parts copy]) : nil;
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [self uploadSubData:data
                   host:host
                 bucket:bucket
         fileNameBase64:fileNameBase64
                  index:index
               uploadId:uploadId
            uploadToken:uploadToken
                success:^(NSDictionary *responseObject) {
        
        NSDictionary *part = @{@"partNumber": [NSNumber numberWithUnsignedInteger:index+1],
                               @"etag": [responseObject objectForKey:@"etag"]
        };
        
        [parts addObject:part];
        
        if (data.length == chunkSize) {
            
            [weakSelf readAndUploadFileInPartialWithFileHandle:fileHandle
                                                         parts:parts
                                                     chunkSize:chunkSize
                                                         index:index+1
                                                fileNameBase64:fileNameBase64
                                                      uploadId:uploadId
                                                   uploadToken:uploadToken
                                                          host:host
                                                        bucket:bucket
                                                     accessKey:accessKey
                                                     secretKey:secretKey
                                                       success:success
                                                       failure:failure];
            
        } else {
            success ? success([parts copy]) : nil;
        }
        
    }
                failure:^(NSError *error) {
        failure ? failure() : nil;
    }];
    
}


#pragma mark - init
- (instancetype)init
{
    self = [super init];
    if (self) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.requestCachePolicy = NSURLRequestReloadIgnoringCacheData;
        config.URLCache = nil;
        NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
        _session = session;
    }
    return self;
}


@end
