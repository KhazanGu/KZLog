//
//  KZFilesManager.h
//  KZLog
//
//  Created by Khazan on 2021/3/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KZFilesManager : NSObject

#pragma mark - redirect standard streams

- (NSString *)redirectStandardStreams;

#pragma mark - all log files

- (NSArray<NSString *> *)allLogFiles;


#pragma mark - get data from path

- (NSData *)dataFromPath:(NSString *)path;


#pragma mark - delete file

- (BOOL)deleteFileWithFilePath:(NSString *)filePath;

#pragma mark - file path

- (NSString *)filePathWithName:(NSString *)fileName;

#pragma mark - now timeInterval

- (NSTimeInterval)now;

@end

NS_ASSUME_NONNULL_END
