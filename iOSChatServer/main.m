//
//  main.m
//  iOSChatServer
//
//  Created by Jeremy Hartmann on 2016-03-11.
//  Copyright © 2016 Jeremy Hartmann. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <CoreFoundation/CoreFoundation.h>
#include <sys/socket.h>
#include <netinet/in.h>
#import "StreamHandle.h"
#import "TCPServer.h"

#pragma mark Main Object
//////////////////////////////////////////////////////////////////////////////////////////
/// Main Object
@interface Main : NSObject
- (void)runServerOnPort:(NSInteger)port;
@end

@interface Main ()
@property TCPServer *server;
@end

@implementation Main

- (void)runServerOnPort:(NSInteger)port
{
    // Setup Stream handle class, start server, and place in runloop.
    self.server = [[TCPServer alloc] initWithPort:port];
}

@end




#pragma mark Main
void connectionHandle (CFSocketRef sref, CFSocketCallBackType callBackType, CFDataRef address, const void *data, void *info)
{
    if (callBackType == kCFSocketAcceptCallBack)
    {
        NSLog(@"SOMETHING IS HAPPENING!");
        
        // Create Read and Write Streams CF
        CFWriteStreamRef writeStream;
        CFReadStreamRef readStream;
        
        // Pair with socket
        CFStreamCreatePairWithSocket(kCFAllocatorDefault, (CFSocketNativeHandle) data, &readStream, &writeStream);
        
        // Cast to NS Stream
        NSInputStream *inStream = (__bridge_transfer NSInputStream *) readStream;
        NSOutputStream *outStream = (__bridge_transfer NSOutputStream *)writeStream;
        
        StreamHandle *streamHandle = [[StreamHandle alloc] initWithStreams:inStream outputStream:outStream];
        
        [streamHandle.iStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [streamHandle.oStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        
        [streamHandle.iStream open];
        [streamHandle.oStream open];
        
        while (streamHandle != nil) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
    }
}
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"iOSChatServer Start");
        
        // Create socket. Pass in a functor callback methoid. connectionHandle
        CFSocketRef serverSocket = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM, IPPROTO_TCP, kCFSocketAcceptCallBack, connectionHandle, NULL);
        
        // Specifies info about port and family
        struct sockaddr_in sin;
        
        // zero buffer
        memset(&sin, 0, sizeof(sin));
        sin.sin_len = sizeof(sin);
        sin.sin_family = AF_INET; // Address family
        sin.sin_port = htons(12354);
        sin.sin_addr.s_addr = INADDR_ANY;
        
        // CFDataRef: object containing a sockaddr struct
        CFDataRef sincfd = CFDataCreate(kCFAllocatorDefault, (UInt8 *) &sin, sizeof(sin));
        
        // Bind socket and sockaddr
        CFSocketSetAddress(serverSocket, sincfd);
        CFRelease(sincfd);
        
        // Add socket to run loop CFSocektCreateRunLoopSource.
        CFRunLoopSourceRef socketSource = CFSocketCreateRunLoopSource(kCFAllocatorDefault, serverSocket, 0);
        
        // Add to run loop
        CFRunLoopAddSource(CFRunLoopGetCurrent(), socketSource, kCFRunLoopDefaultMode);
        
        // Run loop
        CFRunLoopRun();
        
    }
    return 0;
}
