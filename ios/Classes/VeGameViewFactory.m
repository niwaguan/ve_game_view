//
//  VeGameViewFactory.m
//  ve_game_view
//
//  Created by 高洋 on 2024/3/25.
//

#import "VeGameViewFactory.h"
#import "VeGameView.h"

@interface VeGameViewFactory ()

@property(strong, readwrite, nonatomic) NSObject<FlutterBinaryMessenger> *binaryMessenger;

@end

@implementation VeGameViewFactory


+ (instancetype)factoryWithBinaryMessenger:(NSObject<FlutterBinaryMessenger> *)binaryMessenger {
  VeGameViewFactory *factory = [[VeGameViewFactory alloc] init];
  factory.binaryMessenger = binaryMessenger;
  return factory;
}

- (nonnull NSObject<FlutterPlatformView> *)createWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id _Nullable)args { 
  return [VeGameView viewWithFrame:frame binaryMessenger:self.binaryMessenger identifier:viewId arguments:args];
}

@end
