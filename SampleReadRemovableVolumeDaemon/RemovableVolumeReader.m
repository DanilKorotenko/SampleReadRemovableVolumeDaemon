//
//  RemovableVolumeReader.m
//  SampleReadRemovableVolumeDaemon
//
//  Created by Danil Korotenko on 5/5/25.
//

#import "RemovableVolumeReader.h"
#import <DiskArbitration/DiskArbitration.h>
#import <dispatch/dispatch.h>

@implementation RemovableVolumeReader
{
    DASessionRef        _session;
}

+ (NSURL *)volumePathForDisk:(DADiskRef)aDisk
{
    NSURL *volumePathURL = nil;
    CFDictionaryRef descDict = DADiskCopyDescription(aDisk);
    if (descDict)
    {
        NSDictionary *diskDescription = (__bridge NSDictionary *)(descDict);
        volumePathURL = [diskDescription objectForKey:(NSString *)kDADiskDescriptionVolumePathKey];
        CFRelease(descDict);
    }
    return volumePathURL;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _session = DASessionCreate(kCFAllocatorDefault);
    }
    return self;
}

void DiskDescriptionChangedCallback(DADiskRef diskRef, CFArrayRef aKeys, void *context)
{
    NSURL *volumePathURL = [RemovableVolumeReader volumePathForDisk:diskRef];
    if (nil == volumePathURL || 0 == volumePathURL.path.length)
    {
        return;
    }

    RemovableVolumeReader *reader = (__bridge RemovableVolumeReader *)(context);
    [reader readFilesOnVolume:volumePathURL];
}

- (void)start
{
    DARegisterDiskDescriptionChangedCallback(self->_session,
        kDADiskDescriptionMatchVolumeMountable, kDADiskDescriptionWatchVolumePath,
        DiskDescriptionChangedCallback, (__bridge void *)self);

    DASessionScheduleWithRunLoop(self->_session, CFRunLoopGetCurrent(),
        kCFRunLoopCommonModes);
}

- (void)readFilesOnVolume:(NSURL *)aVolumePathURL
{
    NSFileManager *localFileManager= [[NSFileManager alloc] init];

    NSDirectoryEnumerator *directoryEnumerator =
        [localFileManager enumeratorAtURL:aVolumePathURL
            includingPropertiesForKeys:@[NSURLIsDirectoryKey]
            options:NSDirectoryEnumerationSkipsHiddenFiles
            errorHandler:^BOOL(NSURL * _Nonnull url, NSError * _Nonnull error)
            {
                NSLog(@"Volume %@ reading error: %@", url.path, error);
                return NO;
            }];

    if (nil == directoryEnumerator)
    {
        NSLog(@"Volume reading fail");
        return;
    }

    for (NSURL *fileURL in directoryEnumerator)
    {
        NSNumber *isDirectory = nil;
        [fileURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil];
 
        if (![isDirectory boolValue])
        {
            NSError *error = nil;
            NSData *data = [NSData dataWithContentsOfURL:fileURL options:0 error:&error];
            if (nil == data || nil != error)
            {
                NSLog(@"File: %@ reading fail.", fileURL.path);
                if (nil != error)
                {
                    NSLog(@"File: %@ reading error: %@", fileURL.path, error);
                }
            }
            else
            {
                NSLog(@"File: %@ reading success.", fileURL.path);
            }
            break;
        }
    }
}

@end
