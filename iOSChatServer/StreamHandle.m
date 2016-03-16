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
    NSInteger bytesRead = 0;
    NSInteger bufLen = [self.iBuffer length];
    
    // If the buffer is full close connection
    if (bufLen == self.iBufSize)
    {
        [self closeWithError:nil];
    }
    else
    {
        // Set length of buffer to capacity
        [self.iBuffer setLength:self.iBufSize];
        
        // Process the stream
        bytesRead = [self.iStream read:((uint8_t *) [self.iBuffer mutableBytes]) + bufLen maxLength:self.iBufSize - bufLen];
        
        // Check for error
        if (bytesRead <= 0)
        {
            // Error
            [self closeWithError:nil];
        }
        else
        {
            // Set the length of the mutable array
            [self.iBuffer setLength:bytesRead + bufLen];
            
            // Call method to parse the protocol
            [self parseBufferInput];
        }
    }
    
    if (bytesRead > 0)
    {
        // Reset the ibuffer
        [self.iBuffer replaceBytesInRange:NSMakeRange(0, bytesRead) withBytes:NULL length:0];
    }
    
}

/// Parse the data in held inside the iBuffer NSMultableData
- (void)parseBufferInput
{
    // Set length minus CRLF (\n\r)
    NSInteger totalBytesInBuf = [self.iBuffer length];
    NSInteger offset = 0;
    const uint8_t *bytes = [self.iBuffer bytes];
    
    // Minus CR LF
    NSString *inputString = [[NSString alloc] initWithBytes:&bytes[offset] length:totalBytesInBuf - 2 encoding:NSUTF8StringEncoding];
    
    // Process command
    NSArray *command = [inputString componentsSeparatedByString:@":"];
    
    // Check if this is an "iam" add.
    if ([command[0] isEqualToString:@"iam"])
    {
        // add user to group
        NSLog(@"User joined: %@", command[1]);
        
    }
    
    // Check if this is message cmd.
    if ([command[0] isEqualToString:@"msg"])
    {
        // Broadcast message.
        NSLog(@"Message: %@", command[1]);
        
    }
    

}

/// Send string command to clients
- (void)sendStringCmd:(NSString *)command
{
    // Convert into NSData*
    NSData *data = [command dataUsingEncoding:NSUTF8StringEncoding];
    
    // Append to out buffer
    [self.oBuffer appendData:data];
    
    // Write to oStream
    NSInteger bytesWritten = [self.oStream write:[self.oBuffer bytes] maxLength:[self.oBuffer length]];
    
    if (bytesWritten <= 0)
    {
        // Close connection
        [self closeWithError:nil];
    }
    else
    {
        // Zero out out buffer
        [self.oBuffer replaceBytesInRange:NSMakeRange(0, bytesWritten) withBytes:NULL length:0];
    }
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
            [self processInput];
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
