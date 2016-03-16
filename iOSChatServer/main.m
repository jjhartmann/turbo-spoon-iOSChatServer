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
#import "TCPServer.h"

#pragma mark Main Object
//////////////////////////////////////////////////////////////////////////////////////////
/// Main Object
@interface Main : NSObject <TCPServerDelegate>
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
    self.server.delegate = self;
    
    // Start server
    [self.server start];
}

@end




#pragma mark Main
void connectionHandle (CFSocketRef sref, CFSocketCallBackType callBackType, CFDataRef address, const void *data, void *info)
{
//    if (callBackType == kCFSocketAcceptCallBack)
//    {
//        NSLog(@"SOMETHING IS HAPPENING!");
//        
//        // Create Read and Write Streams CF
//        CFWriteStreamRef writeStream;
//        CFReadStreamRef readStream;
//        
//        // Pair with socket
//        CFStreamCreatePairWithSocket(kCFAllocatorDefault, (CFSocketNativeHandle) data, &readStream, &writeStream);
//        
//        // Cast to NS Stream
//        NSInputStream *inStream = (__bridge_transfer NSInputStream *) readStream;
//        NSOutputStream *outStream = (__bridge_transfer NSOutputStream *)writeStream;
//        
//        StreamHandle *streamHandle = [[StreamHandle alloc] initWithStreams:inStream outputStream:outStream];
//        
//        [streamHandle.iStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
//        [streamHandle.oStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
//        
//        [streamHandle.iStream open];
//        [streamHandle.oStream open];
//        
//        while (streamHandle != nil) {
//            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
//        }
//    }
}
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"iOSChatServer Start");
        
//        if (argc < 2)
//        {
//            NSLog(@"Provide Port number <1-65534>");
//            return 1;
//        }
        
        Main *mainObj = [[Main alloc]init];
        
//        NSInteger port = atoi(argv[1]);
        [mainObj runServerOnPort:12345];
    }
    return 0;
}
