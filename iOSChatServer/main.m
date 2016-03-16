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
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"iOSChatServer Start");
        
        if (argc < 2)
        {
            NSLog(@"Provide Port number <1-65534>");
            return 1;
        }
        
        Main *mainObj = [[Main alloc]init];
        
        NSInteger port = atoi(argv[1]);
        NSLog(@"Running on port: %li", port);
        
        [mainObj runServerOnPort:port];
    }
    return 0;
}
