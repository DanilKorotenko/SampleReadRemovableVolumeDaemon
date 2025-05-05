//
//  main.m
//  SampleReadRemovableVolumeDaemon
//
//  Created by Danil Korotenko on 5/5/25.
//

#import <Foundation/Foundation.h>

#import "RemovableVolumeReader.h"

int main(int argc, const char * argv[])
{
    RemovableVolumeReader *reader = [[RemovableVolumeReader alloc] init];
    [reader start];
    dispatch_main();
    return 0;
}
