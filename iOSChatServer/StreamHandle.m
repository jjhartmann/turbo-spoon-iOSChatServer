//
//  StreamHandle.m
//  iOSChatServer
//
//  Created by Jeremy Hartmann on 2016-03-12.
//  Copyright © 2016 Jeremy Hartmann. All rights reserved.
//

#import "StreamHandle.h"

@interface StreamHandle ()
@property (nonatomic, readwrite, strong) NSMutableData *iBuffer;
@property (nonatomic, readwrite, strong) NSMutableData *oBuffer;
@property BOOL hasSpaceAvailable;
@end

@implementation StreamHandle

/// Init with input and output streams
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

/// Open the connections to the streams and add to current run loop
- (void)open
{
    assert(self.isOpen == NO);
    
    // Set input and outbut buffer
    if (self.iBufSize == 0)
    {
        self.iBufSize = 16 * 1024;
    }
    if (self.oBufSize == 0)
    {
        self.oBufSize = 16 * 1024;
    }
    
    // Create empty buffer
    self.iBuffer = [NSMutableData dataWithCapacity:self.iBufSize];
    self.oBuffer = [NSMutableData dataWithCapacity:self.oBufSize];
    
    //Add to current run loop
    [self.iStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.oStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];

    // Open connections
    [self.iStream open];
    [self.oStream open];
    
    self.isOpen = YES;
}


/// Close connection with reference to an error
- (void)closeWithError:(NSError *)error
{
    if (self.isOpen)
    {
        // Set delgates to nil
        [self.iStream setDelegate:nil];
        [self.oStream setDelegate:nil];
        
        // Remove the streams from the run loop
        [self.iStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.oStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        
        // Close the stream
        [self.iStream close];
        [self.oStream close];
    }
}

/// Process the input form the stream
- (void)processInput
{
    // Use the member variable self.ibuffer.
 
        
}

#pragma mark -
#pragma mark NSStream Delegate Methods
-(void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    // Check stream with self.
    assert(aStream == self.iStream || aStream == self.oStream);
    
    // Demultiplex the messages.
    switch (eventCode) {
        case NSStreamEventOpenCompleted:
        {
            break;
        }
        case NSStreamEventHasBytesAvailable: // Read from stream
        {
            
            break;
        }
        case NSStreamEventHasSpaceAvailable: // Write to stream
        {
            break;
        }
        case NSStreamEventEndEncountered: // End of stream
        {
            break;
        }
        case NSStreamEventErrorOccurred: // Error in Stream
        {
            break;
        }
        default:
            break;
    }
    
    
}

@end
