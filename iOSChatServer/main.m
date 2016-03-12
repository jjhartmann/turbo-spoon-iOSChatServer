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


void connectionHandle (CFSocketRef sref, CFSocketCallBackType callBackType, CFDataRef address, const void *data, void *info)
{
    NSLog(@"SOMETHING IS HAPPENING!");
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
        sin.sin_port = htons(12345);
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
