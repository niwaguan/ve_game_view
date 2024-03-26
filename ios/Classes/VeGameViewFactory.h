//
//  VeGameViewFactory.h
//  ve_game_view
//
//  Created by 高洋 on 2024/3/25.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

@interface VeGameViewFactory : NSObject<FlutterPlatformViewFactory>

@property(strong, readonly, nonatomic) NSObject<FlutterBinaryMessenger> *binaryMessenger;

+ (instancetype)factoryWithBinaryMessenger:(NSObject<FlutterBinaryMessenger> *)binaryMessenger;

@end

NS_ASSUME_NONNULL_END
