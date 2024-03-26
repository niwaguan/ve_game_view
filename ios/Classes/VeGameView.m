//
//  VeGameView.m
//  ve_game_view
//
//  Created by 高洋 on 2024/3/25.
//

#import "VeGameView.h"
#import "Constants.h"

@interface VeGameView ()

@property(nonatomic, strong, readwrite) UIView *iView;
@property(nonatomic, strong, readwrite) FlutterMethodChannel *methodChannel;

@end

@implementation VeGameView

+ (instancetype)viewWithFrame:(CGRect)frame
              binaryMessenger:(NSObject<FlutterBinaryMessenger> *)binaryMessenger
                   identifier:(int64_t)identifier
                    arguments:(id _Nullable)args {
  VeGameView *view = [[VeGameView alloc] init];
  view.iView = [[UIView alloc] initWithFrame:frame];
  [view buildView];
  view.methodChannel = [FlutterMethodChannel methodChannelWithName:[NSString stringWithFormat:@"%@.%lld", VeGameViewTypeID, identifier] binaryMessenger:binaryMessenger];
  
  typeof(view) __weak weak = view;
  [view.methodChannel setMethodCallHandler:^(FlutterMethodCall * _Nonnull call, FlutterResult  _Nonnull result) {
    [weak onFlutterMethodCall:call result:result];
  }];
  return view;
}

- (void)buildView {
  _iView.backgroundColor = [UIColor redColor];
}

- (nonnull UIView *)view {
  return _iView;
}


- (void)onFlutterMethodCall:(FlutterMethodCall * _Nonnull)call result:(FlutterResult _Nonnull)result {
  
}

@end
