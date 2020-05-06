//
//  RequestMap.m
//  LSWearable
//
//  Created by rolandxu on 12/18/15.
//  Copyright © 2015 lifesense. All rights reserved.
//

#import "RequestMap.h"

static NSString *const kLSWDefaultConfigKey = @"release";

static NSString *const kLSWInfoFileName = @"Info";
static NSString *const kLSWHostFileName = @"host";

static NSString *const kLSWStaticHostFileName = @"staticHost";
static NSString *const kLSWWebsocketHostFileName = @"websocketHost";
static NSString *const KLSWHostFileKeyName = @"urlHost";

static NSString *const kLSWProtocolFileName = @"protocol";

static NSString *const kLSWFileType = @"plist";

static NSString *const kLSWProtocolUrlKey = @"url";
static NSString *const kLSWProtocolRequestKey = @"request";
static NSString *const kLSWProtocolDescKey = @"desc";
static NSString *const kLSWProtocolResponseKey = @"response";

static NSString *const kLSWDefaultHostKey = @"DEFAULT_HOST_KEY";

static NSString *const kLSWCurrentConfigFileName = @"kLSWCurrentConfigFileName.plist";
static NSString *const kLSWAllConfigsFileName = @"kLSWAllConfigsFileName.plist";

static NSString *const kLSWReleaseKey = @"release";
static NSString *const kLSWDevKey = @"dev";
static NSString *const kLSWQaKey = @"qa";
static NSString *const kLSWQa2Key = @"qa2";
static NSString *const KLSWPrereleaseKey = @"prerelease";   // pre - release


NSString *const kLSWConfigCustomType = @"custom";
NSString *const kLSWConfigDevType = @"dev";  // dev
NSString *const kLSWConfigQaType = @"qa";  // qa
NSString *const kLSWConfigQa2Type = @"qa2";  // qa2
NSString *const kLSWConfigReleaseType = @"release";  // release
NSString *const KLSWConfigPrereleaseKey = @"prerelease"; // pre - release

NSString *const kLSWConfigHostKey = @"kLSWConfigHostKey";
NSString *const kLSWConfigStaticHostKey = @"kLSWConfigStaticHostKey";
NSString *const kLSWConfigWebSocketKey = @"kLSWConfigWebSocketKey";
NSString *const kLSWConfigTypeKey = @"kLSWConfigTypeKey";


@interface RequestMap ()

@property (nonatomic, copy)NSString *cachePath;

@property (nonatomic, copy) NSString *currentHost;
@property (nonatomic, copy) NSString *currentStaticHost;
@property (nonatomic, copy) NSString *currentWebsocketHost;
@property (nonatomic, copy) NSString *currentConfigType;

@property (nonatomic, copy) NSDictionary *allHostDict;
@property (nonatomic, copy) NSDictionary *hostDict;
@property (nonatomic, copy) NSDictionary *staticHostDict;
@property (nonatomic, copy) NSDictionary *websocketHostDict;
@property (nonatomic, copy) NSMutableDictionary *protocolDict;

@property (nonatomic, copy) NSMutableDictionary *currentConfig;

@property (nonatomic, strong) NSMutableArray <NSDictionary *> *tempConfigs;


@end

@implementation RequestMap

#pragma mark - LifeCycle
- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupCache];
    }
    return self;
}

#pragma mark - Public
static RequestMap *gRequestMap =nil;

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gRequestMap = [[RequestMap alloc] init];
    });
    
    return gRequestMap;
}

+ (void)cleanUp {
    gRequestMap = nil;
}

- (nullable NSString *)getRequestV2UrlByName:(NSString *)name {
    NSString *format = [self.protocolDict objectForKey:name][kLSWProtocolUrlKey];
    if ([self.currentConfigType isEqualToString:kLSWConfigReleaseType]) {
        
        if (![format hasPrefix:@"%@/rpm"]) {
            NSString *host = @"https://sports.lifesense.com";
            return [NSString stringWithFormat:format, host];
        }
    }
    
    return [NSString stringWithFormat:format, self.currentHost];
}

- (nullable NSString *)getResponseV2ByName:(NSString *)name {
    return [self.protocolDict objectForKey:name][kLSWProtocolResponseKey];
}

- (void)addWithConfigDict:(NSDictionary *)configDict {
    NSCParameterAssert(configDict);
    if ([self checkConfigHasContained:configDict]) {
        return;
    }
    NSString *allConfigsPath = [self.cachePath stringByAppendingPathComponent:kLSWAllConfigsFileName];
    [self.tempConfigs addObject:[configDict copy]];
    [[self.tempConfigs copy] writeToFile:allConfigsPath atomically:YES];
}

- (void)deleteWithConfigDict:(NSDictionary *)configDict {
    NSCParameterAssert(configDict);
    
    [self.tempConfigs enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj[kLSWConfigHostKey] isEqualToString:configDict[kLSWConfigHostKey]]
            && [obj[kLSWConfigStaticHostKey] isEqualToString:configDict[kLSWConfigStaticHostKey]]
            && [obj[kLSWConfigWebSocketKey] isEqualToString:configDict[kLSWConfigWebSocketKey]]) {
            [self.tempConfigs removeObject:configDict];
            NSString *allConfigsPath = [self.cachePath stringByAppendingPathComponent:kLSWAllConfigsFileName];
            [[self.tempConfigs copy] writeToFile:allConfigsPath atomically:YES];
            *stop = YES;
        }
    }];
    
    
    
}

- (void)setWithConfigDict:(NSDictionary *)configDict {
    NSAssert([self checkConfigHasContained:configDict], @"设置的configDict 要存在");
    self.currentConfig = [configDict copy];
    NSString *configFilePath = [self.cachePath stringByAppendingPathComponent:kLSWCurrentConfigFileName];
    [self.currentConfig writeToFile:configFilePath atomically:YES];
}

#pragma mark - Private


- (void)setupCache {
    
    NSString *protocolFilePath = [RequestMap getFilePathWithFileName:kLSWProtocolFileName];
    NSString *hostFilePath = [RequestMap getFilePathWithFileName:kLSWHostFileName];
    
    _protocolDict = [NSMutableDictionary dictionary];
    _currentConfig = [[NSMutableDictionary alloc] init];
    _tempConfigs = [[NSMutableArray alloc] init];
    
    NSArray *protocolFileArr = [NSArray arrayWithContentsOfFile:protocolFilePath];
    for (NSString *pfname in protocolFileArr) {
        NSString *pfPath = [RequestMap getFilePathWithFileName:pfname];
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:pfPath];
        NSArray *allkeys = [dict allKeys];
        for (NSString *key in allkeys) {
            id val = [dict objectForKey:key];
            [_protocolDict setObject:val forKey:key];
        }
    }
    
    _allHostDict = [NSDictionary dictionaryWithContentsOfFile:hostFilePath];
    
    _hostDict = [_allHostDict objectForKey:KLSWHostFileKeyName];
    _staticHostDict = [_allHostDict objectForKey:kLSWStaticHostFileName];
    _websocketHostDict = [_allHostDict objectForKey:kLSWWebsocketHostFileName];
    
    //NSString *defaultKey = [RequestMap getDefaultHostKey];
    NSString *defaultKey = [[NSUserDefaults standardUserDefaults] stringForKey:kLSWDefaultHostKey];
    if ([defaultKey length]<=0) {
        defaultKey = [RequestMap getDefaultHostKey];
        
        //保存一个
        [[NSUserDefaults standardUserDefaults] setObject:defaultKey forKey:kLSWDefaultHostKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    NSString *configFilePath = [self.cachePath stringByAppendingPathComponent:kLSWCurrentConfigFileName];

#ifndef POD_CONFIGURATION_RELEASE
     
    NSString *allConfigsPath = [self.cachePath stringByAppendingPathComponent:kLSWAllConfigsFileName];
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    if (![fileManager fileExistsAtPath:allConfigsPath]) { //文件不存在
//        [fileManager copyItemAtPath:hostFilePath toPath:allConfigsPath error:nil];
//    }
    
    _currentConfig = [NSMutableDictionary dictionaryWithContentsOfFile:configFilePath];
    if (!_currentConfig || [_currentConfig count]<=0) {
        NSMutableDictionary *configDict = [NSMutableDictionary dictionaryWithCapacity:3];
        
        configDict[kLSWConfigHostKey] = _hostDict[defaultKey];
        configDict[kLSWConfigStaticHostKey] = _staticHostDict[defaultKey];
        configDict[kLSWConfigWebSocketKey] = _websocketHostDict[defaultKey];
        
        [configDict writeToFile:configFilePath atomically:YES];
        _currentConfig = [configDict copy];
    }
    
    NSArray *temparr = [NSArray arrayWithContentsOfFile:allConfigsPath];
    if ([temparr count] > 0) {
        [_tempConfigs addObjectsFromArray:temparr];
    }
    else {
        NSMutableDictionary *releaseConfig = [NSMutableDictionary dictionaryWithCapacity:3];
        releaseConfig[kLSWConfigHostKey] = _hostDict[kLSWReleaseKey];
        releaseConfig[kLSWConfigStaticHostKey] = _staticHostDict[kLSWReleaseKey];
        releaseConfig[kLSWConfigWebSocketKey] = _websocketHostDict[kLSWReleaseKey];
        releaseConfig[kLSWConfigTypeKey] = kLSWConfigReleaseType;
        
        [_tempConfigs addObject:releaseConfig];
        
        
        NSMutableDictionary *devConfig = [NSMutableDictionary dictionaryWithCapacity:3];
        devConfig[kLSWConfigHostKey] = _hostDict[kLSWDevKey];
        devConfig[kLSWConfigStaticHostKey] = _staticHostDict[kLSWDevKey];
        devConfig[kLSWConfigWebSocketKey] = _websocketHostDict[kLSWDevKey];
        devConfig[kLSWConfigTypeKey] = kLSWConfigDevType;
        
        [_tempConfigs addObject:devConfig];
        
        NSMutableDictionary *qaConfig = [NSMutableDictionary dictionaryWithCapacity:3];
        qaConfig[kLSWConfigHostKey] = _hostDict[kLSWQaKey];
        qaConfig[kLSWConfigStaticHostKey] = _staticHostDict[kLSWQaKey];
        qaConfig[kLSWConfigWebSocketKey] = _websocketHostDict[kLSWQaKey];
        qaConfig[kLSWConfigTypeKey] = kLSWConfigQaType;
        
        [_tempConfigs addObject:qaConfig];
        
        
        NSMutableDictionary *qa2Config = [NSMutableDictionary dictionaryWithCapacity:3];
        qa2Config[kLSWConfigHostKey] = _hostDict[kLSWQa2Key];
        qa2Config[kLSWConfigStaticHostKey] = _staticHostDict[kLSWQa2Key];
        qa2Config[kLSWConfigWebSocketKey] = _websocketHostDict[kLSWQa2Key];
        qa2Config[kLSWConfigTypeKey] = kLSWConfigQa2Type;
        
        [_tempConfigs addObject:qa2Config];
        
        [[_tempConfigs copy] writeToFile:allConfigsPath atomically:YES];
    }

#else
    NSMutableDictionary *configDict = [NSMutableDictionary dictionaryWithCapacity:3];
    configDict[kLSWConfigHostKey] = _hostDict[defaultKey];
    configDict[kLSWConfigStaticHostKey] = _staticHostDict[defaultKey];
    configDict[kLSWConfigWebSocketKey] = _websocketHostDict[defaultKey];
    
    [configDict writeToFile:configFilePath atomically:YES];
    _currentConfig = [configDict copy];
#endif

}

- (BOOL)checkConfigHasContained:(NSDictionary *)config {
    __block BOOL hasContained = NO;
    [self.tempConfigs enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj[kLSWConfigHostKey] isEqualToString:config[kLSWConfigHostKey]]
            && [obj[kLSWConfigStaticHostKey] isEqualToString:config[kLSWConfigStaticHostKey]]
            && [obj[kLSWConfigWebSocketKey] isEqualToString:config[kLSWConfigWebSocketKey]]) {
            hasContained = YES;
            *stop = YES;
        }
    }];
    
    return hasContained;
}

#pragma mark - Getters
- (NSMutableArray *)allConfigs {
    return [self.tempConfigs copy];
}

- (NSString *)currentHost {
    return self.currentConfig[kLSWConfigHostKey];
}

- (NSString *)currentStaticHost {
    return self.currentConfig[kLSWConfigStaticHostKey];
}

- (NSString *)currentWebsocketHost {
    return self.currentConfig[kLSWConfigWebSocketKey];
}

- (NSString *)currentConfigType {
    return self.currentConfig[kLSWConfigTypeKey];
}

- (NSString *)cachePath {
    if (_cachePath == nil) {
        NSArray *cachePathArray = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        _cachePath = [cachePathArray objectAtIndex:0];
    }
    return _cachePath;
}

+ (NSString *)getFilePathWithFileName:(NSString *)fileName {
    return [[NSBundle mainBundle] pathForResource:fileName ofType:kLSWFileType];
}

+ (NSString *)getDefaultHostKey {
    NSString* File = [self getFilePathWithFileName:kLSWInfoFileName] ;
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:File];
    NSString *key = [dict objectForKey:kLSWDefaultHostKey];
    if ([key length] > 0)
    {
        return key;
    }
    return kLSWDefaultConfigKey;
}

- (void)addProtocolWithFilePath:(NSString *)filePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:filePath];
        NSArray *allkeys = [dict allKeys];
        for (NSString *key in allkeys) {
            id val = [dict objectForKey:key];
            [_protocolDict setObject:val forKey:key];
        }
    }
    else {
#ifdef DEBUG
        NSAssert(0, @"文件不存在");
#endif
    }
}

//更改默认的 key, 建议只提供 dev, qa, qa2, release 这四种值
-(BOOL)changeDefaultHostKey:(NSString *)key {
    
    if ([key length]<=0) {
        return NO;
    }
    
    if (![key isEqualToString:kLSWDevKey] && ![key isEqualToString:kLSWQaKey] && ![key isEqualToString:kLSWQa2Key]  && ![key isEqualToString:kLSWReleaseKey]) {
        return NO; //不是指定的key
    }
    
    NSMutableDictionary *configDict = [NSMutableDictionary dictionaryWithCapacity:3];
    
    configDict[kLSWConfigHostKey] = _hostDict[key];
    configDict[kLSWConfigStaticHostKey] = _staticHostDict[key];
    configDict[kLSWConfigWebSocketKey] = _websocketHostDict[key];
    
    NSString *configFilePath = [self.cachePath stringByAppendingPathComponent:kLSWCurrentConfigFileName];
    [configDict writeToFile:configFilePath atomically:YES];
    _currentConfig = [configDict copy];
    
    [[NSUserDefaults standardUserDefaults] setObject:key forKey:kLSWDefaultHostKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return YES;
}

//更改默认的host，默认的key不变, 主要用来更改服务端下发的host
-(BOOL)changeDefaultHost:(NSString *)hostLink {
    NSString *configFilePath = [self.cachePath stringByAppendingPathComponent:kLSWCurrentConfigFileName];
    
    //覆盖host
    [self.currentConfig setValue:hostLink forKey:kLSWConfigHostKey];
    return [self.currentConfig writeToFile:configFilePath atomically:YES];
}

//取得协议地址，直接返回。这个返回是直接返回plist里面的配置的url。
- (nullable NSString *)getOriginRequestUrl:(NSString *)name {
    return [self.protocolDict objectForKey:name][kLSWProtocolUrlKey];
}

@end
