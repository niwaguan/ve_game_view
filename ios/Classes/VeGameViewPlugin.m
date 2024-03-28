#import "VeGameViewPlugin.h"
#import "VeGameViewFactory.h"
#import "Constants.h"
#import <VeGame/VeGame.h>

@implementation VeGameViewPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:VeGameViewTypeID
            binaryMessenger:registrar.messenger];
  
  VeGameViewPlugin *plugin = [[VeGameViewPlugin alloc] init];
  [registrar addMethodCallDelegate:plugin channel:channel];
  
  [registrar registerViewFactory:[VeGameViewFactory factoryWithBinaryMessenger:registrar.messenger] withId:VeGameViewTypeID];
}


// TODO: 实现来自Flutter端的调用
- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"init" isEqualToString:call.method]) {
       [[VeGameManager sharedInstance] initWithAccountId:call.arguments[@"accountId"]];
    }
}

@end
