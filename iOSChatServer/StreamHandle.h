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
@property (nonatomic, strong) NSInputStream *iStream;
@property (nonatomic, strong) NSOutputStream *oStream;
@property NSMutableSet *runLoopModesSet;
@property NSInteger iBufSize;
@property NSInteger oBufSize;
@property BOOL isOpen;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) id <StreamHandleDelegate> delegate;

- (id) initWithStreams:(NSInputStream *)is outputStream:(NSOutputStream *)os;
- (void)open;
- (void)closeWithError:(NSError *)error;
- (void)processInput;
- (void)parseBufferInput;
- (void)sendStringCmd:(NSString *)command;

@end


@protocol StreamHandleDelegate <NSObject>

- (void)proccessIAmCommand:(NSString *)name;
- (void)processsMsgCommand:(NSString *)message;
- (void)closeConnectionHandle:(StreamHandle *)handle;

@end