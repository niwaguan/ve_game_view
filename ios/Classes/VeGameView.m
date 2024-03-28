//
//  VeGameView.m
//  ve_game_view
//
//  Created by 高洋 on 2024/3/25.
//

#import "VeGameView.h"
#import "Constants.h"
#import <VeGame/VeGame.h>
#import <CommonCrypto/CommonDigest.h>
#import <CoreMotion/CoreMotion.h>

@interface VeCloudGameConfigObject : NSObject

@property (nonatomic, assign) BOOL netProbe;
@property (nonatomic, copy) NSString *ak;
@property (nonatomic, copy) NSString *sk;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *gameId;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *roundId;

@end
@interface VeGameView ()<VeGameManagerDelegate>

@property (nonatomic, assign) BOOL alreadyStart;
@property(nonatomic, strong, readwrite) UIView *iView;
@property(nonatomic, strong, readwrite) FlutterMethodChannel *methodChannel;
@property (nonatomic, copy) NSString *operationDelayTime;
@property (nonatomic, strong) UILabel *netProbeStatsLabel;
@property (nonatomic, strong, readwrite) UIView *containerView;
@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, assign) double last_motion_x;
@property (nonatomic, assign) double last_motion_y;
@property (nonatomic, strong) VeCloudGameConfigObject *configObj;

@property (nonatomic, assign) NSInteger rotation;
@end

@implementation VeGameView

+ (instancetype)viewWithFrame:(CGRect)frame
              binaryMessenger:(NSObject<FlutterBinaryMessenger> *)binaryMessenger
                   identifier:(int64_t)identifier
                    arguments:(id _Nullable)args {
    [[VeGameManager sharedInstance] initWithAccountId:@"------AccountID------"];
  VeGameView *view = [[VeGameView alloc] init];
        VeCloudGameConfigObject *obj = [[VeCloudGameConfigObject alloc] init];
        obj.ak=@"";
        obj.sk=@"";
        obj.token=@"";
        obj.userId=@"";
        obj.gameId=@"";
        obj.roundId=@"";
        obj.netProbe=true;
  view.iView = [[UIView alloc] initWithFrame:frame];
    view.configObj=obj;
  [view buildView];
  view.methodChannel = [FlutterMethodChannel methodChannelWithName:[NSString stringWithFormat:@"%@.%lld", VeGameViewTypeID, identifier] binaryMessenger:binaryMessenger];
  
  typeof(view) __weak weak = view;
  [view.methodChannel setMethodCallHandler:^(FlutterMethodCall * _Nonnull call, FlutterResult  _Nonnull result) {
    [weak onFlutterMethodCall:call result:result];
  }];
  return view;
}

- (void)buildView {
    [self configSubView];
    self.rotation = 0;
    [VeGameManager sharedInstance].containerView = self.iView;
    VeGameConfigObject *configObj = [VeGameConfigObject new];
    configObj.ak = self.configObj.ak;
    configObj.sk = self.configObj.sk;
    configObj.token = self.configObj.token;
    configObj.userId = self.configObj.userId;
    [[VeGameManager sharedInstance] probeStart: configObj];

    [VeGameManager sharedInstance].delegate = self;
  _iView.backgroundColor = [UIColor redColor];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(receiveAppWillTerminateNotification:)
                                                 name: UIApplicationWillTerminateNotification
                                               object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(receiveAppDidEnterBackgroundNotification:)
                                                 name: UIApplicationDidEnterBackgroundNotification
                                               object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(receiveAppWillEnterForegroundNotification:)
                                                 name: UIApplicationWillEnterForegroundNotification
                                               object: nil];
}
- (void)configSubView
{
    // 画布
    self.iView = ({
        UIView *containerView = [[UIView alloc] init];
        containerView.backgroundColor = [UIColor blackColor];
        [self.view addSubview: containerView];
        containerView;
    });
}
- (nonnull UIView *)view {
  return _iView;
}

- (void)startGame
{
    if (!self.alreadyStart) {
        self.alreadyStart = YES;
        // 启动参数
        VeGameConfigObject *configObj = [VeGameConfigObject new];
        configObj.ak = self.configObj.ak;
        configObj.sk = self.configObj.sk;
        configObj.token = self.configObj.token;
        configObj.userId = self.configObj.userId;
        configObj.gameId = self.configObj.gameId;
        configObj.roundId = self.configObj.roundId;
        // 启动
        [[VeGameManager sharedInstance] startWithConfig: configObj];
    }
}


- (void)onFlutterMethodCall:(FlutterMethodCall * _Nonnull)call result:(FlutterResult _Nonnull)result {
  
}
#pragma mark - receive notification

- (void)receiveAppWillTerminateNotification:(NSNotification *)notification
{
    [[VeGameManager sharedInstance] stop];
}

- (void)receiveAppDidEnterBackgroundNotification:(NSNotification *)notification
{
    [[VeGameManager sharedInstance] switchPaused: YES];
}

- (void)receiveAppWillEnterForegroundNotification:(NSNotification *)notification
{
    [[VeGameManager sharedInstance] switchPaused: NO];
}

@end
