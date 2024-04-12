//
//  SendMessageEntry.h
//  ve_game_view
//
//  Created by 高洋 on 2024/4/12.
//

#import <Foundation/Foundation.h>

@class FlutterMethodCall;

NS_ASSUME_NONNULL_BEGIN

typedef void (^FlutterResult)(id _Nullable result);

@interface SendMessageEntry : NSObject

@property (nonatomic, strong, readwrite) FlutterMethodCall *call;
@property (nonatomic, copy, readwrite) FlutterResult result;

@end

NS_ASSUME_NONNULL_END
