//
//  KZFilesManager.m
//  KZLog
//
//  Created by Khazan on 2021/3/15.
//

#import "KZFilesManager.h"
#import "KZLogConstants.h"

@implementation KZFilesManager

// stderr no buffer
// stdout line buffer
- (NSString *)redirectStandardStreams {
    NSString *newfilepath = [self filePathWithName:[NSString stringWithFormat:@"KZLog%.0f", [self now]]];
    const char *cnewfilepath = [newfilepath cStringUsingEncoding:NSASCIIStringEncoding];
    
    freopen(cnewfilepath, "a+", stderr);
    FILE *stream = freopen(cnewfilepath, "a+", stdout);
    // set no buffer
    setbuffer(stream, NULL, 0);
    
    return newfilepath;
}

#pragma mark - all log files

- (NSArray<NSString *> *)allLogFiles {
    NSMutableArray *filesArr = [NSMutableArray arrayWithCapacity:0];
    NSString *documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSArray *documentsDirectoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectoryPath
                                                                                              error:NULL];
    //    KZLOG(@"douc: %@", documentsDirectoryPath);
    for (NSString *curFileName in [documentsDirectoryContents objectEnumerator]) {
        
        NSString *filePath = [documentsDirectoryPath stringByAppendingPathComponent:curFileName];
        //        NSURL *fileURL = [NSURL fileURLWithPath:filePath];
        //        KZLOG(@"filePath: %@", filePath);
        
        BOOL isDirectory;
        [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory];
        
        if (!isDirectory && [curFileName hasPrefix:@"KZLog"]) {
            [filesArr addObject:filePath];
        }
    }
    
    return [filesArr copy];
}


#pragma mark - get data from path

- (NSData *)dataFromPath:(NSString *)path {
    return [NSData dataWithContentsOfFile:path];
}

#pragma mark - delete file

- (BOOL)deleteFileWithFilePath:(NSString *)filePath {
    BOOL result = 1;
    NSURL *url = [NSURL fileURLWithPath:filePath];
    NSError *error;
    
    result = [[NSFileManager defaultManager] removeItemAtURL:url error:&error];
    return result;
}

#pragma mark - file path

- (NSString *)filePathWithName:(NSString *)fileName {
    NSArray *documents = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [documents lastObject];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:fileName];
    KZLOG(@"file path:%@", filePath);
    return filePath;
}

#pragma mark - timeInterval

- (NSTimeInterval)now {
    return [[NSDate date] timeIntervalSince1970];
}


@end
