//
//  TCPServer.h
//  iOSChatServer
//
//  Created by Jeremy Hartmann on 2016-03-14.
//  Copyright © 2016 Jeremy Hartmann. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TCPServerDelegate;

@interface TCPServer : NSObject
@property id <TCPServerDelegate> delegate;
@property NSInteger portNumber;

- (id) initWithPort:(NSInteger)port;

@end


@protocol TCPServerDelegate <NSObject>


@end