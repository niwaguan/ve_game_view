#import "VeGameViewPlugin.h"
#import "VeGameViewFactory.h"
#import "Constants.h"

@implementation VeGameViewPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [registrar registerViewFactory:[VeGameViewFactory factoryWithBinaryMessenger:registrar.messenger] withId:VeGameViewTypeID];
}

@end
