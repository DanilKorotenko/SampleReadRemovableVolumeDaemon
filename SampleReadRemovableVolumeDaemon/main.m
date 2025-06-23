//
//  main.m
//  SampleReadRemovableVolumeDaemon
//
//  Created by Danil Korotenko on 5/5/25.
//

#import <Foundation/Foundation.h>

#import "RemovableVolumeReader.h"
#import "IOUsbUtils/UAdapter.hpp"

int main(int argc, const char * argv[])
{
    RemovableVolumeReader *reader = [[RemovableVolumeReader alloc] init];
    [reader start];

    IOUSBStartWatchingWithBlock(
        ^(USBDeviceRef aDevice)
        {
            NSLog(@"mtp device connected.");
        });

    [[NSRunLoop currentRunLoop] run];
    return 0;
}
