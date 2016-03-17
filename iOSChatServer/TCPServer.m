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

#pragma mark connection Handle functor callback
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

#pragma mark TCPServer Methods
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
        _usernameStreamIDDictionary = [[NSMutableDictionary alloc] init];
                
        // Set up group-username-stream map
        _groupIDStreamIDStreamHandleDictionary = [[NSMutableDictionary alloc] init];
        [_groupIDStreamIDStreamHandleDictionary setObject:[[NSMutableDictionary alloc] init] forKey:@"public"];
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
    handle.streamID = [NSString stringWithFormat:@"%li", self.streamHandleSeqNumber];
    self.streamHandleSeqNumber++;
    handle.delegate = self;
    [handle open];
    
    // Set stream inside map indexed by <group> <id>
    [[self.groupIDStreamIDStreamHandleDictionary objectForKey:@"public"] setObject:handle forKey:handle.streamID];
}


#pragma mark Stream Handle Callbacks
/// Process the message command and broadcast to all connections
- (void)processsMsgCommand:(NSString *)message context:(StreamHandle *)context
{
    // Broadcast message to all connected clients
    NSMutableDictionary *groupDict = [self.groupIDStreamIDStreamHandleDictionary objectForKey:@"public"];
    for (NSString *key in groupDict)
    {
        StreamHandle *obj = [groupDict objectForKey:key];
        if (obj != context)
            [obj sendStringCmd:[NSString stringWithFormat:@"From: %@.\nMessage: %@ \n", context.UserName, message]];
    }
    
    // send calling context success
    [context sendStringCmd:@"msgsent:YES\n"];
}

/// Process message with group param
- (void)processMsgToGrp:(NSString *)message group:(NSString *)group context:(StreamHandle *)context
{
    // Broadcast message to all connected clients
    NSMutableDictionary *groupDict = [self.groupIDStreamIDStreamHandleDictionary objectForKey:group];
    
    // Get if group is avaliable, if not create.
    if (!groupDict)
    {
        NSLog(@"Creating Group: %@", group);
        [self.groupIDStreamIDStreamHandleDictionary setObject:[NSMutableDictionary new] forKey:group];
        [[self.groupIDStreamIDStreamHandleDictionary objectForKey:group] setObject:context forKey:context.streamID];
        
        // Send calling client message that groups has been added.
        [context sendStringCmd:@"grpcreate:YES\n"];
        [context sendStringCmd:@"msgsent:NO\n"];
        return;
    }
    
    BOOL contextInGroup = ([groupDict objectForKey:context.streamID] == context);
    if (!contextInGroup)
    {
        // Add context and send confirmation
        [groupDict setObject:context  forKey:context.streamID];
        [context sendStringCmd:[NSString stringWithFormat:@"subgrp:%@\n", group]];
    }
    
    // If group is currently available
    for (NSString *streamID in groupDict)
    {
        StreamHandle *obj = [groupDict objectForKey:streamID];
        if (obj != context)
            [obj sendStringCmd:[NSString stringWithFormat:@"From: %@.\nMessage: %@ \n", context.UserName, message]];
    }
    
    // send calling context success
    [context sendStringCmd:@"msgsent:YES\n"];
}

/// Process the iam command and add user to connection
- (void)proccessIAmCommand:(NSString *)name context:(StreamHandle *)context
{
    NSString *tmp = [self.usernameStreamIDDictionary objectForKey:name];

    if (!tmp)
    {
        // If not in map, add
        [self.usernameStreamIDDictionary setObject:context.streamID forKey:name];
        
        context.UserName = name;
        [context sendStringCmd:[NSString stringWithFormat:@"addusercb:YES\n"]];
    }
    else
    {
        // Name alread taken
        [context sendStringCmd:[NSString stringWithFormat:@"addusercb:NO\n"]];
    }
    
    
}

/// Process when a connection closes
- (void)closeConnectionHandle:(NSString *)username context:(StreamHandle *)context
{
    // Remove stream from set
    for (NSMutableDictionary *d in self.groupIDStreamIDStreamHandleDictionary)
    {
        [[self.groupIDStreamIDStreamHandleDictionary objectForKey:d] removeObjectForKey:context.streamID];
    }
    
    [self.usernameStreamIDDictionary removeObjectForKey:context.UserName];
}

@end
