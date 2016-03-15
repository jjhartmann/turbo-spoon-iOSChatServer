//
//  StreamHandle.m
//  iOSChatServer
//
//  Created by Jeremy Hartmann on 2016-03-12.
//  Copyright © 2016 Jeremy Hartmann. All rights reserved.
//

#import "StreamHandle.h"

@interface StreamHandle ()

@end

@implementation StreamHandle

// Init with input and output streams
- (id)initWithStreams:(NSInputStream *)is outputStream:(NSOutputStream *)os
{
    self = [super init];
    if (self != nil)
    {
        // Initialise streams
        _iStream = is;
        _oStream = os;
        
        [_iStream setDelegate:self];
        [_oStream setDelegate:self];
    }
    return self;
}

#pragma mark -
#pragma mark NSStream Delegate Methods
-(void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    // Do something
    NSLog(@"STREAM Handle called.");
}

@end
