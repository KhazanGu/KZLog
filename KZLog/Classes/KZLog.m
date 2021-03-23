//
//  KZLog.m
//  Pods-KZLog_Example
//
//  Created by Khazan on 2021/3/15.
//

#import "KZLog.h"
#import "KZFilesManager.h"
#import "KZUploadViaDataSplit.h"
#import "KZLogConstants.h"
#import <sys/utsname.h>

@interface KZLog ()
@property (nonatomic, strong) KZUploadViaDataSplit *uploader;
@end

@implementation KZLog

- (void)syncAllLogsToQiNiuWithHost:(NSString *)host
                            bucket:(NSString *)bucket
                         accessKey:(NSString *)accessKey
                         secretKey:(NSString *)secretKey {
    
    self.uploader = [[KZUploadViaDataSplit alloc] init];
    
    KZFilesManager *manager = [[KZFilesManager alloc] init];
    NSArray<NSString *> *files = [manager allLogFiles];
    NSUInteger chunkSize = 1024 * 1024 * 4;
    NSString *format = [self formatFileName];
    
    [manager redirectStandardStreams];
    
    [self uploadViaPathWithFilePaths:files
                               index:0
                           chunkSize:chunkSize
                              format:format
                                host:host
                              bucket:bucket
                           accessKey:accessKey
                           secretKey:secretKey];
    
    
    [self uploadViaDataWithFilePaths:files
                           chunkSize:chunkSize
                              format:format
                                host:host
                              bucket:bucket
                           accessKey:accessKey
                           secretKey:secretKey];


    [self uploadViaPathWithFilePaths:files
                           chunkSize:chunkSize
                              format:format
                                host:host
                              bucket:bucket
                           accessKey:accessKey
                           secretKey:secretKey];
}


// upload full data files at the same time, big memory use.
- (void)uploadViaDataWithFilePaths:(NSArray<NSString *> *)filePaths
                         chunkSize:(NSUInteger)chunkSize
                            format:(NSString *)format
                              host:(NSString *)host
                            bucket:(NSString *)bucket
                         accessKey:(NSString *)accessKey
                         secretKey:(NSString *)secretKey {
    
    [filePaths enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSData *data = [NSData dataWithContentsOfFile:obj];
        NSString *fileName = [self newFileNameWithFilePath:obj format:format];
        __weak typeof(self) weakSelf = self;
        
        [self.uploader splitDataAndUploadWithData:data
                                        chunkSize:chunkSize
                                         fileName:fileName
                                             host:host
                                           bucket:bucket
                                        accessKey:accessKey
                                        secretKey:secretKey
                                          success:^{
            [weakSelf uploaded:obj];
        }
                                          failure:^{
        }];
        
    }];
}

// upload files at the same time, split one file data to parts, low memory use
- (void)uploadViaPathWithFilePaths:(NSArray<NSString *> *)filePaths
                         chunkSize:(NSUInteger)chunkSize
                            format:(NSString *)format
                              host:(NSString *)host
                            bucket:(NSString *)bucket
                         accessKey:(NSString *)accessKey
                         secretKey:(NSString *)secretKey {
    
    [filePaths enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        __weak typeof(self) weakSelf = self;
        
        [self uploadWithFilePath:obj
                       chunkSize:chunkSize
                          format:format
                            host:host
                          bucket:bucket
                       accessKey:accessKey
                       secretKey:secretKey
                         success:^{
            
            [weakSelf uploaded:obj];
            
        } failure:^{
            
        }];
        
    }];
}

// upload file one by one, split one file data to parts, very low memory use
- (void)uploadViaPathWithFilePaths:(NSArray<NSString *> *)filePaths
                             index:(NSUInteger)index
                         chunkSize:(NSUInteger)chunkSize
                            format:(NSString *)format
                              host:(NSString *)host
                            bucket:(NSString *)bucket
                         accessKey:(NSString *)accessKey
                         secretKey:(NSString *)secretKey {
    
    if (filePaths.count <= index) {
        return;
    }
    NSString *filePath = filePaths[index];
    
    __weak typeof(self) weakSelf = self;
    
    [self uploadWithFilePath:filePath
                   chunkSize:chunkSize
                      format:format
                        host:host
                      bucket:bucket
                   accessKey:accessKey
                   secretKey:secretKey
                     success:^{
        
        [weakSelf uploaded:filePath];
        
        [weakSelf uploadViaPathWithFilePaths:filePaths
                                       index:index+1
                                   chunkSize:chunkSize
                                      format:format
                                        host:host
                                      bucket:bucket
                                   accessKey:accessKey
                                   secretKey:secretKey];
        
    }
                     failure:^{
        
        [weakSelf uploadViaPathWithFilePaths:filePaths
                                       index:index+1
                                   chunkSize:chunkSize
                                      format:format
                                        host:host
                                      bucket:bucket
                                   accessKey:accessKey
                                   secretKey:secretKey];
        
    }];
    
}

// split one file data to parts and upload
- (void)uploadWithFilePath:(NSString *)filePath
                 chunkSize:(NSUInteger)chunkSize
                    format:(NSString *)format
                      host:(NSString *)host
                    bucket:(NSString *)bucket
                 accessKey:(NSString *)accessKey
                 secretKey:(NSString *)secretKey
                   success:(void (^)(void))success
                   failure:(void (^)(void))failure {
    
    NSString *fileName = [self newFileNameWithFilePath:filePath format:format];
    
    [self.uploader readAndUploadFileInPartialWithFilePath:filePath
                                                chunkSize:chunkSize
                                                 fileName:fileName
                                                     host:host
                                                   bucket:bucket
                                                accessKey:accessKey
                                                secretKey:secretKey
                                                  success:success
                                                  failure:failure];
}


// upload success
- (void)uploaded:(NSString *)filePath {
    [self deleteFile:filePath];
}

// delete file after uploaded
- (void)deleteFile:(NSString *)filePath {
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:filePath] error:&error];
    KZLOG(@"uploaded:%@ error:%@", filePath, error);
}

// file name on qiniu cloud
- (NSString *)newFileNameWithFilePath:(NSString *)filePath format:(NSString *)format {
    NSString *fileName = [filePath lastPathComponent];
    NSString *timeInterval = [fileName stringByReplacingOccurrencesOfString:@"KZLog" withString:@""];
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:[timeInterval doubleValue]];
    NSString *newFileName = [NSString stringWithFormat:@"%@_%@", format, date];
    return newFileName;
}

// file name format
- (NSString *)formatFileName {
    NSString *name = [NSString stringWithFormat:@"%@_%@(%@)_%@%@_%@(%@)", KZ_APP_NAME, KZ_APP_VERSION, KZ_BUILD_VERSION, KZ_SYSTEM_NAME, KZ_SYSTEM_VERSION, [self deviceName], KZ_DEVICE_NAME];
    return name;
}

// device name
- (NSString *)deviceName {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString* code = [NSString stringWithCString:systemInfo.machine
                                        encoding:NSUTF8StringEncoding];
    return code;
}

// Prevent being released
+ (KZLog *)sharedInstance {
    static KZLog *log = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        log = [[KZLog alloc] init];
    });
    return log;
}


@end
