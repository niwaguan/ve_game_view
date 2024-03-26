//
//  VeGameView.h
//  ve_game_view
//
//  Created by 高洋 on 2024/3/25.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

@interface VeGameView : NSObject<FlutterPlatformView>

+ (instancetype)viewWithFrame:(CGRect)frame
              binaryMessenger:(NSObject<FlutterBinaryMessenger> *)binaryMessenger
                   identifier:(int64_t)identifier
                    arguments:(id _Nullable)args;

@end

NS_ASSUME_NONNULL_END
