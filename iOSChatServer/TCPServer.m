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

@interface TCPServer ()
@property CFSocketRef socket;

@end

@implementation TCPServer


- (id)initWithPort:(NSInteger)port
{
    self = [super init];
    if (self)
    {
        assert(port > 0 && port < 65535);
        _portNumber = port;
        
        // Create socket. Pass in a functor callback methoid. connectionHandle. TODO: replace nil with connection Handle.
        _socket = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM, IPPROTO_TCP, kCFSocketAcceptCallBack, nil, NULL);
        
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
        CFSocketSetAddress(_socket, sincfd);
        CFRelease(sincfd);
        
        // Add socket to run loop CFSocektCreateRunLoopSource.
        CFRunLoopSourceRef socketSource = CFSocketCreateRunLoopSource(kCFAllocatorDefault, _socket, 0);
        
        // Add to run loop
        CFRunLoopAddSource(CFRunLoopGetCurrent(), socketSource, kCFRunLoopDefaultMode);

    }
    
    return self;
}

@end
