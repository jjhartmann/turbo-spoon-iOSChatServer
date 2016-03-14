//
//  StreamHandle.h
//  iOSChatServer
//
//  Created by Jeremy Hartmann on 2016-03-12.
//  Copyright © 2016 Jeremy Hartmann. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol StreamHandleDelegate;

@interface StreamHandle : NSObject <NSStreamDelegate>
@property NSInputStream *iStream;
@property NSOutputStream *oStream;

- (id) initWithStreams:(NSInputStream *)is outputStream:(NSOutputStream *)os;

@end
