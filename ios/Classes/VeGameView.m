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

/** ---------------- 鼠标按钮类型 ----------------- */
typedef NS_ENUM(NSUInteger, VeGameMouseButtonType) {
    /** 左键 */
    VeGameMouseButtonTypeLeft = 0,
    /** 中间 */
    VeGameMouseButtonTypeMiddle,
    /** 右键 */
    VeGameMouseButtonTypeRight,
    /** XButton1 */
    VeGameMouseButtonTypeXButton1,
    /** XButton2 */
    VeGameMouseButtonTypeXButton2
};


@interface VeCloudGameConfigObject : NSObject

@property (nonatomic, assign) BOOL netProbe;
@property (nonatomic, copy) NSString *ak;
@property (nonatomic, copy) NSString *sk;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *gameId;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *roundId;
@property (nonatomic, copy) NSString *reservedId;


@end

@implementation VeCloudGameConfigObject
@end
/** ------------ 鼠标操作 ------------- */
@interface VeGameMouseMessage : NSObject
/**
 * 当 action = VeGameMouseActionTypeMove 时，为游戏画面 X 轴相对值，差值
 * 当 action = VeGameMouseActionTypeCursorPos 时，为游戏画面 X 轴绝对值，[0, 1]
 */
@property (nonatomic, assign) CGFloat x;
/**
 * 当 action = VeGameMouseActionTypeMove 时，为游戏画面 Y 轴相对值，差值
 * 当 action = VeGameMouseActionTypeCursorPos 时，为游戏画面 Y 轴绝对值，[0, 1]
 */
@property (nonatomic, assign) CGFloat y;
/**
 * 滚轮值
 */
@property (nonatomic, assign) int32_t wheel;


/**
 * 按钮类型
 */
@property (nonatomic, assign) VeGameMouseButtonType button;
/**
 * 动作类型
 */
@property (nonatomic, assign) VeGameMouseActionType action;
@end


@implementation VeGameMouseMessage
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
    configObj.reservedId=self.configObj.reservedId;
    
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
    [self startGame];
    
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
        configObj.reservedId = self.configObj.reservedId;
        configObj.sessionMode=2;
        [VeGameManager sharedInstance].streamType=VeBaseStreamTypeVideo;
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
        obj.reservedId=call.arguments[@"reservedId"];
        obj.netProbe=false;
        self.configObj=obj;
        [self buildView];
    }else if ([@"stop" isEqualToString:call.method]) {
        
        [[VeGameManager sharedInstance] stop];
    }
}
#pragma mark - receive notification

- (void)receiveAppWillTerminateNotification:(NSNotification *)notification
{
    [[VeGameManager sharedInstance] stop];
    [self.methodChannel invokeMethod:@"onStreamStarted" arguments:nil];
}

- (void)receiveAppDidEnterBackgroundNotification:(NSNotification *)notification
{
    [[VeGameManager sharedInstance] switchPaused: YES];
    [self.methodChannel invokeMethod:@"onStreamPaused" arguments:nil];
}

- (void)receiveAppWillEnterForegroundNotification:(NSNotification *)notification
{
    [[VeGameManager sharedInstance] switchPaused: NO];
    [self.methodChannel invokeMethod:@"onStreamResumed" arguments:nil];
}


- (void)dealloc {
    // 在这里执行视图销毁前的清理操作
    // 例如移除通知、释放资源等
    [[VeGameManager sharedInstance] stop];

}
- (void)gameManager:(VeGameManager *)manager onMessageChannleError:(VeGameErrorCode)errCode
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSNumber *codeNum = @(errCode);
        NSString *toast = @"";
        if (errCode == ERROR_MESSAGE_GENERAL) {
            toast = @"50000 消息通道通用错误";
        } else if (errCode == ERROR_MESSAGE_NOT_CONNECTED) {
            toast = @"50001 消息通道无连接";
        } else if (errCode == ERROR_MESSAGE_FAILED_TO_PARSE_MSG) {
            toast = @"50002 消息通道数据解析失败";
        } else if (errCode == ERROR_MESSAGE_CHANNEL_UID_ILLEGAL) {
            toast = @"50003 消息通道ID非法";
        } else if (errCode == ERROR_MESSAGE_OVER_SIZED) {
            toast = @"50007 消息体超过60kb";
        } else if (errCode == ERROR_MESSAGE_TIMEOUT_ILLEGAL) {
            toast = @"50009 消息发送超时时间非法";
        }
        if (toast.length > 0) {
            
            [self.methodChannel invokeMethod:@"onMessageError" arguments:@{@"code":codeNum,@"message":toast}];
        }
    });
}
- (void)gameManager:(VeGameManager *)manager connectionChangedToState:(VeBaseConnectionState)state{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSNumber *stateNum = @(state);
        [self.methodChannel invokeMethod:@"onStreamConnectionStateChanged" arguments:@{@"state":stateNum}];
        
    });
}
//本地流数据统计
- (void)gameManager:(VeGameManager *)manager onLocalStreamStats:(VeBaseLocalStreamStats *)stats
{
//     NSLog(@"local stream stats: %@", [stats description]);
    
}
//远端流数据统计
- (void)gameManager:(VeGameManager *)manager onRemoteStreamStats:(VeBaseRemoteStreamStats *)stats
{
    dispatch_async(dispatch_get_main_queue(), ^{

        
        
        [self.methodChannel invokeMethod:@"onStreamStats" arguments:@{@"receivedVideoBitRate":@(stats.receivedVideoKBitrate),@"receivedAudioBitRate":@(stats.receivedAudioKBitrate),@"decoderOutputFrameRate":@(stats.decoderOutputFrameRate),@"rendererOutputFrameRate":@(stats.rendererOutputFrameRate),@"receivedResolutionHeight":@(stats.height),@"receivedResolutionWidth":@(stats.width),@"videoLossRate":@(stats.videoLossRate),@"rtt":@(stats.videoRtt),@"stallCount":@(stats.videoStallCount),@"stallDuration":@(stats.videoStallDuration),@"frozenRate":@(stats.receivedVideoKBitrate)}];

    });
}
/// 本地“操作延迟”回调
/// - Parameters:
///   - manager: VeGameManager 对象
///   - delayTime: 时间 ms
- (void)gameManager:(VeGameManager *)manager operationDelay:(NSInteger)delayTime{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.methodChannel invokeMethod:@"onDetectDelay" arguments:@{@"elapse":@(delayTime)}];
        
    });
}
/// 远端“旋转”回调
/// - Parameters:
///   - manager: VeGameManager 对象
///   - rotation: 旋转度
- (void)gameManager:(VeGameManager *)manager changedDeviceRotation:(NSInteger)rotation{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.methodChannel invokeMethod:@"onRotation" arguments:@{@"rotation":@(rotation)}];
        
    });
}

- (void)gameManager:(VeGameManager *)manager onWarning:(VeGameWarningCode)warnCode
{
    
    NSNumber *codeNum = @(warnCode);
    NSString *toast = @"";
    if (warnCode == WARNING_START_NO_STOP_BEFORE) {
        toast = @"10010 启动游戏失败，原因：连续调用了两次Start之间没有调用 Stop";
    } else if (warnCode == WARNING_START_INVALID_AUTO_RECYCLE_TIME) {
        toast = @"10019 设置无操作回收服务时长非法";
    } else if (warnCode == WARNING_START_WITH_FRAMEWORK_NOT_FOUND) {
        toast = @"10023 伴随程序：全部未找到";
    } else if (warnCode == WARNING_START_WITH_FRAMEWORK_PART_MATCH) {
        toast = @"10024 伴随程序：部分找到";
    } else if (warnCode == WARNING_START_WITH_FRAMEWORK_WRONG_INPUT_FORMAT) {
        toast = @"10025 伴随程序：格式错误，解析失败";
    } else if (warnCode == WARNING_QUEUEING_LACK_RESOURCE) {
        toast = @"10030 还需要继续排队";
    } else if (warnCode == WARNING_SDK_LACK_OF_LOCATION_PERMISSION) {
        toast = @"30007 无定位权限";
    } else if (warnCode == WARNING_VIEWER_METHOD_CALLED) {
        toast = @"30011 VeBaseRoleTypeViewer 操作被调用";
    } else if (warnCode == WARNING_LOCAL_ALREADY_SET_BACKGROUND) {
        toast = @"40037 用户重复调用切换后台接口";
    } else if (warnCode == WARNING_LOCAL_ALREADY_SET_FOREGROUND) {
        toast = @"40038 用户重复调用切换前台接口";
    } else if (warnCode == WARNING_GAME_STOPPED_INGAME_EXIT) {
        toast = @"40044 游戏实例退出";
    } else if (warnCode == WARNING_VIDEO_PROFILE_NOT_SUPPORT_CURRENT_PLAN) {
        toast = @"40052 套餐不支持";
    } else if (warnCode == WARNING_START_NET_REQUEST_CANCEL) {
        toast = @"61001 网络请求取消";
    }
    
    [self.methodChannel invokeMethod:@"onWarning" arguments:@{@"code":codeNum,@"message":toast}];
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

- (void)gameManager:(VeGameManager *)manager onPodExit:(VeGameErrorCode)errCode
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSNumber *codeNum = @(errCode);
        NSString *toast = @"";
        if (errCode == ERROR_GAME_ABNORMAL_EXIT) {
            toast = @"40000 云端游戏异常退出";
        } else if (errCode == ERROR_GAME_CRASH) {
            toast = @"40001 云端游戏崩溃";
        } else if (errCode == ERROR_GAME_STOPPED_IDLE) {
            toast = @"40004 长期未操作，云端游戏自动断开";
        } else if (errCode == ERROR_GAME_STOPPED_API) {
            toast = @"40006 服务端主动停止云端游戏";
        } else if (errCode == ERROR_POD_STOPPED_BACKGROUND_TIMEOUT) {
            toast = @"40008 云端后台超时";
        } else if (errCode == ERROR_POD_EXIT_GENERAL) {
            toast = @"40009 云端游戏退出";
        } else if (errCode == MESSAGE_RESOURCE_RELEASED_NORMAL) {
            toast = @"40023 实例正常释放";
        } else if (errCode == MESSAGE_RESOURCE_RELEASED_NO_USER) {
            toast = @"40024 实例异常释放：客户端超时未加入";
        } else if (errCode == MESSAGE_RESOURCE_RELEASED_OS_MISSED) {
            toast = @"40026 实例异常释放：游戏镜像缺失";
        } else if (errCode == MESSAGE_RESOURCE_RELEASED_GAME_START_FAILURE) {
            toast = @"40027 实例异常释放：游戏启动失败";
        } else if (errCode == MESSAGE_RESOURCE_RELEASED_STREAMING_ERROR) {
            toast = @"40028 实例异常释放：rtc推流成功，但是推流过程中出现异常";
        } else if (errCode == MESSAGE_RESOURCE_RELEASED_3RD_APP_MISSED) {
            toast = @"40029 实例异常释放：伴随包镜像缺失";
        } else if (errCode == MESSAGE_3RD_APP_START_FAILURE) {
            toast = @"40031 伴随包启动失败";
        } else if (errCode == MESSAGE_CLOUD_GAME_CRASH_OFTEN) {
            toast = @"40032 游戏频繁崩溃";
        } else if (errCode == MESSAGE_GAME_STEAMING_FAILURE) {
            toast = @"40033 Rtc推流不成功";
        } else if (errCode == MESSAGE_RESOURCE_RELEASED_INVALID_PARAMETER) {
            toast = @"40047 Pod收到的参数非法";
        } else if (errCode == MESSAGE_RESOURCE_RELEASED_HEART_BEAT_TIMEOUT) {
            toast = @"40048 实例离线";
        } else if (errCode == MESSAGE_RESOURCE_RELEASED_INGAME_EXIT) {
            toast = @"40049 游戏侧主动退出";
        } else if (errCode == MESSAGE_RESOURCE_RELEASED_START_ERROR_ARCHIVE_DOWNLOAD_FAILURE) {
            toast = @"40050 存档下载失败，Pod启动失败";
        } else if (errCode == ERROR_GAME_EXIT_INTERNAL_ERROR) {
            toast = @"40051 内部错误，云服务重启或GS重启";
        }
        if (toast.length > 0) {
            [self.methodChannel invokeMethod:@"onPodExit" arguments:@{@"reason":codeNum,@"msg":toast}];
        }
    });
}
/// “网络质量”回调
/// - Parameters:
///   - manager: VeGameManager 对象
///   - quality: 网络质量
- (void)gameManager:(VeGameManager *)manager onNetworkQuality:(VeBaseNetworkQuality)quality{
    dispatch_async(dispatch_get_main_queue(), ^{
        
    
        [self.methodChannel invokeMethod:@"onNetworkQuality" arguments:@{@"quality":@(quality)}];
        
    });
}

- (void)gameManager:(VeGameManager *)manager onQueueUpdate:(NSArray<NSDictionary *> *)queueInfoList
{
    [self.methodChannel invokeMethod:@"onQueueUpdate" arguments:queueInfoList];
    NSLog(@"开始排队：%@", queueInfoList);
}

- (void)gameManager:(VeGameManager *)manager onQueueSuccessAndStart:(NSInteger)remainTime
{
    [self.methodChannel invokeMethod:@"onQueueSuccessAndStart" arguments:@{@"remainTime":@(remainTime),}];
    NSLog(@"排队完毕%ld", remainTime);
}



#pragma mark - VeGameManagerDelegate

- (void)firstRemoteAudioFrameArrivedFromGameManager:(VeGameManager *)manager
{
    NSLog(@"--- 收到首帧音频 ---");
    [self.methodChannel invokeMethod:@"onFirstAudioFrame" arguments:nil];
}

- (void)firstRemoteVideoFrameArrivedFromGameManager:(VeGameManager *)manager
{
    NSLog(@"--- 收到首帧视频 ---");
    [self.methodChannel invokeMethod:@"onFirstVideoFrame" arguments:nil];
}


#pragma mark - 业务拓展

- (void)configMotion {
    // 创建 CMMotionManager 对象
    _motionManager = [[CMMotionManager alloc] init];
    [_motionManager startGyroUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMGyroData * _Nullable gyroData, NSError * _Nullable error) {
        VeGameMouseMessage *move = [VeGameMouseMessage new];
        move.x = (self.last_motion_x - gyroData.rotationRate.y) * 5;
        move.y = (self.last_motion_y - gyroData.rotationRate.x) * 5;
        NSLog(@"%f,%f,",move.x,move.y);
        [[VeGameManager sharedInstance] sendMoveEventWithAbsX:gyroData.rotationRate.x absY:gyroData.rotationRate.y deltaX:self.last_motion_x deltaY:self.last_motion_y];
        self.last_motion_x = gyroData.rotationRate.y;
        self.last_motion_y = gyroData.rotationRate.x;
        //                button.center = CGPointMake(button.center.x - gyroData.rotationRate.y * 5, button.center.y - gyroData.rotationRate.x * 5);
    }];
}


@end
