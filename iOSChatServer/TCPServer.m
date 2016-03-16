//
//  TCPServer.m
//  iOSChatServer
//
//  Created by Jeremy Hartmann on 2016-03-14.
//  Copyright © 2016 Jeremy Hartmann. All rights reserved.
//

#import "TCPServer.h"
#include <CoreFoundation/CoreFoundation.h>
#include <sys/socket.h>
#include <netinet/in.h>
#import "StreamHandle.h"

@interface TCPServer ()
@property CFSocketRef socket;

@end

@implementation TCPServer

/// Functor to handle callbacks to from socket connection
static void connectionHandle(CFSocketRef sref, CFSocketCallBackType type, CFDataRef address, const void *data, void *info)
{
    TCPServer *obj = (__bridge TCPServer*)info;
    assert([obj isKindOfClass:[TCPServer class]]);
    
    // Read incoming data. // Set up streams
    int fileDescriptor = *(const int *)data;
    
    // Create connection with file descriptor.
    if (type  == kCFSocketAcceptCallBack)
    {
        [obj streamAcceptedWithSocket:fileDescriptor];
    }
}

/// Init with port number and set up initial server settings on IPv4
- (id)initWithPort:(NSInteger)port
{
    self = [super init];
    if (self)
    {
        assert(port > 0 && port < 65535);
        _portNumber = port;
        const CFSocketContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
        
        // Create socket. Pass in a functor callback methoid. connectionHandle. TODO: replace nil with connection Handle.
        _socket = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM, IPPROTO_TCP, kCFSocketAcceptCallBack, connectionHandle, &context);
        
        // Specifies info about port and family
        struct sockaddr_in sin;
        
        // zero buffer
        memset(&sin, 0, sizeof(sin));
        sin.sin_len = sizeof(sin);
        sin.sin_family = AF_INET; // Address family
        sin.sin_port = htons(port);
        sin.sin_addr.s_addr = INADDR_ANY;
        
        // CFDataRef: object containing a sockaddr struct
        CFDataRef sincfd = CFDataCreate(kCFAllocatorDefault, (UInt8 *) &sin, sizeof(sin));
        
        // Bind socket and sockaddr
        CFSocketSetAddress(_socket, sincfd);
        CFRelease(sincfd);
        
        // Add socket to run loop CFSocektCreateRunLoopSource.
        CFRunLoopSourceRef socketSource = CFSocketCreateRunLoopSource(kCFAllocatorDefault, _socket, 0);
        
        // Add to run loop
        CFRunLoopAddSource(CFRunLoopGetCurrent(), socketSource, kCFRunLoopDefaultMode);
        
        // Create Mutable array to store stream handles
        _streamHandleMutable = [[NSMutableArray alloc] init];
        _streamHandleSeqNumber = 0;
    }
    
    return self;
}

/// Start the server and entire into runloop
- (void)start
{
    // Start the run loop.
    CFRunLoopRun();
}

/// Create a stream hanble on the connection and add to NSMutable Array. 
- (void)streamAcceptedWithSocket:(NSInteger)fd
{

    NSLog(@"SOMETHING IS HAPPENING!");
    
    // Create Read and Write Streams CF
    CFWriteStreamRef writeStream;
    CFReadStreamRef readStream;
    
    // Pair with socket
    CFStreamCreatePairWithSocket(kCFAllocatorDefault, (CFSocketNativeHandle) fd, &readStream, &writeStream);
    
    // Cast to NS Stream
    NSInputStream *inStream = (__bridge_transfer NSInputStream *) readStream;
    NSOutputStream *outStream = (__bridge_transfer NSOutputStream *)writeStream;
    
    // Create new Stream handle and add to mutable array
    StreamHandle *handle = [[StreamHandle alloc] initWithStreams:inStream outputStream:outStream];
    handle.name = [NSString stringWithFormat:@"%zu", self.streamHandleSeqNumber];
    self.streamHandleSeqNumber++;
    [handle open];
    
    [self.streamHandleMutable addObject:handle];
}

@end
