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
#import <Flutter/Flutter.h>

@interface VeCloudGameConfigObject : NSObject

@property (nonatomic, assign) BOOL netProbe;
@property (nonatomic, copy) NSString *ak;
@property (nonatomic, copy) NSString *sk;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *gameId;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *roundId;

@end

@implementation VeCloudGameConfigObject
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
@property (nonatomic, assign) int  roundIdCount;

@property (nonatomic, assign) NSInteger rotation;
@end

@implementation VeGameView

+ (instancetype)viewWithFrame:(CGRect)frame
              binaryMessenger:(NSObject<FlutterBinaryMessenger> *)binaryMessenger
                   identifier:(int64_t)identifier
                    arguments:(id _Nullable)args {
    VeGameView *view = [[VeGameView alloc] init];
    view.iView = [[UIView alloc] initWithFrame:frame];
    view.methodChannel = [FlutterMethodChannel methodChannelWithName:[NSString stringWithFormat:@"%@.%lld", VeGameViewTypeID, identifier] binaryMessenger:binaryMessenger];
    
    typeof(view) __weak weak = view;
    [view.methodChannel setMethodCallHandler:^(FlutterMethodCall * _Nonnull call, FlutterResult  _Nonnull result) {

                  
        [weak onFlutterMethodCall:call result:result];
    }];
    return view;
}

- (void)buildView {
//    [self configSubView];
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
    NSLog(@"View frame: %@", NSStringFromCGRect(_iView.frame));

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
    [self.iView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];

    
}
// 然后实现观察者方法
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    if (object == self.view && [keyPath isEqualToString:@"frame"]) {
        CGRect newFrame = [[change objectForKey:NSKeyValueChangeNewKey] CGRectValue];
        NSLog(@"View's frame has changed: %@", NSStringFromCGRect(newFrame));
        
        // 在这里可以执行你想要做的操作，比如重新布局等
        [self startGame];
    }
}
- (void)configSubView
{
    // 画布
//    self.iView = ({
//        UIView *containerView = [[UIView alloc] init];
//        containerView.backgroundColor = [UIColor blackColor];
//        [self.view addSubview: containerView];
//        containerView;
//    });
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

    NSLog(@"%@", call.arguments);
    if ([@"start" isEqualToString:call.method]) {
        self.roundIdCount++;
        VeCloudGameConfigObject *obj = [[VeCloudGameConfigObject alloc] init];
        if(call.arguments[@"roundId"]!=nil){
            
            obj.roundId=call.arguments[@"roundId"];
        }else{
            obj.roundId=[NSString stringWithFormat:@"%@%d", call.arguments[@"uid"], self.roundIdCount];
        }
        obj.ak=call.arguments[@"ak"];
        obj.sk=call.arguments[@"sk"];
        obj.token=call.arguments[@"token"];
        obj.userId=call.arguments[@"uid"];
        obj.gameId=call.arguments[@"gameId"];
        obj.netProbe=false;
        self.configObj=obj;
        [self buildView];
    }
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

- (void)gameManager:(VeGameManager *)manager changedDeviceRotation:(NSInteger)rotation
{
    // 横竖屏方向回调，注意：SDK只负责横竖屏方向回调，不负责横竖屏的旋转，业务方需根据rotation自行处理
}

- (void)gameManager:(VeGameManager *)manager onWarning:(VeGameWarningCode)warnCode
{
    // 警告回调
}

- (void)gameManager:(VeGameManager *)manager onError:(VeGameErrorCode)errCode
{
    NSNumber *codeNum = @(errCode);
    NSString *toast = @"";
    if (errCode == ERROR_START_GENERAL) {
        toast = @"10000 通用错误";
    } else if (errCode == ERROR_START_AUTHENTICATION_FAILED) {
        toast = @"10001 火山服务鉴权失败";
    } else if (errCode == ERROR_START_GAME_ID_OR_CUSTOM_GAME_ID_NOT_EXIST) {
        toast = @"10002 当前游戏不存在";
    } else if (errCode == ERROR_START_GAME_ID_NOT_READY) {
        toast = @"10003 当前游戏尚在适配中";
    } else if (errCode == ERROR_START_CONFIGURATION_CODE_NOT_EXIST) {
        toast = @"10004 套餐 ID 不存在";
    } else if (errCode == ERROR_START_CONFIGURATION_CODE_NOT_REDAY) {
        toast = @"10005 套餐 ID 未就绪";
    } else if (errCode == ERROR_START_RESOURCE_NOT_READY) {
        toast = @"10006 当前游戏订购资源未就绪";
    } else if (errCode == ERROR_START_RESOURCE_CAPACITY_NOT_ENOUGH) {
        toast = @"10007 当前游戏没有订购资源";
    } else if (errCode == ERROR_START_AUTHENTICATION_KEY_FAILED) {
        toast = @"10009 鉴权 Token 过期";
    } else if (errCode == ERROR_START_CONNECTION_ENDED) {
        toast = @"10011 启动游戏失败，原因：在调用Start接口后，Start成功回调触发前，游戏被停止";
    } else if (errCode == ERROR_START_RESERVED_ID_NOT_FOUND) {
        toast = @"10012 ReservedId 不存在";
    } else if (errCode == ERROR_START_RESERVED_ID_EXPIRED) {
        toast = @"10013 ReservedId 过期";
    } else if (errCode == ERROR_START_RESERVED_ID_ALREADY_USED_RELEASE) {
        toast = @"10014 ReservedId 无效";
    } else if (errCode == ERROR_START_RESERVED_ID_USING) {
        toast = @"10015 ReservedId 已被使用";
    } else if (errCode == ERROR_START_RESERVED_ID_MISMATCH_PREPARE) {
        toast = @"10016 ReservedId 相应的预锁定与 Start 参数不匹配";
    } else if (errCode == ERROR_START_NO_SUFFICIENT_FUND) {
        toast = @"10017 后付费账户欠费，服务不可用";
    } else if (errCode == ERROR_START_USER_CONFLICT) {
        toast = @"10018 触发了游戏多开限制，建议：请联系火山技术之";
    } else if (errCode == ERROR_START_MISMATCH_ACCOUNTID) {
        toast = @"10026 AccountId错误";
    } else if (errCode == ERROR_START_INVALID_LOCAL_TIME) {
        toast = @"10027 本地时间导致token过期";
    } else if (errCode == ERROR_START_INVALID_ROLE) {
        toast = @"10028 观察者启用挂机模式报错";
    } else if (errCode == ERROR_USER_NOT_IN_QUEUE) {
        toast = @"10029 退出排队队列";
    } else if (errCode == ERROR_STREAM_GENERAL) {
        toast = @"20000 游戏串流连接错误";
    } else if (errCode == ERROR_STREAM_CHANGE_CLARITY_ID_NOT_IN_START_STATE) {
        toast = @"20002 切换清晰度失败，原因：在非播放状态下";
    } else if (errCode == ERROR_SDK_GENERAL) {
        toast = @"30000 SDK 通用错误";
    } else if (errCode == ERROR_SDK_INIT_FAILED) {
        toast = @"30001 初始化 SDK 实例化失败";
    } else if (errCode == ERROR_SDK_CONFIG_OR_AUTH_PARAMETER_EMPTY) {
        toast = @"30002 启动参数为空";
    } else if (errCode == ERROR_SDK_INVALID_VIDEO_CONTAINER) {
        toast = @"30008 画布尺寸无效";
    } else if (errCode == ERROR_INIT_ACCOUNT_ID_ILLEGAL) {
        toast = @"30009 火山账户ID非法";
    } else if (errCode == ERROR_NET_PROBE_FAILED) {
        toast = @"32000 网络探测失败";
    } else if (errCode == ERROR_FIRST_FRAME_TIME_OUT) {
        toast = @"33001 首帧超时";
    } else if (errCode == ERROR_GAME_STOPPED_DUPLICATE_START) {
        toast = @"游戏停止，原因：在不同设备上使用相同参数请求Start";
    } else if (errCode == ERROR_NET_REQUEST_ERROR) {
        toast = @"60001 网络请求失败";
    } else if (errCode == ERROR_HTTP_REQUEST_ERROR) {
        toast = @"60002 网络请求失败";
    }
    [self.methodChannel invokeMethod:@"onError" arguments:@{@"code":codeNum,@"message":toast}];
  
    // 错误回调
}

@end
