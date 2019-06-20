#import "BuglyCrashPlugin.h"
#import <Bugly/Bugly.h>

@implementation BuglyCrashPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"bugly_crash"
            binaryMessenger:[registrar messenger]];
  BuglyCrashPlugin* instance = [[BuglyCrashPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else if ([@"initCrashReport" isEqualToString:call.method]) {
      NSString *appId = call.arguments[@"appId"];
      BOOL b = [self isBlankString:appId];
      if(!b){
          BuglyConfig * config = [[BuglyConfig alloc] init];
          NSString *channel = call.arguments[@"channel"];
          BOOL isChannelEmpty = [self isBlankString:channel];
          if(!isChannelEmpty){
            config.channel = channel;
          }
          [Bugly startWithAppId:appId config:config];
          NSLog(@"Bugly appId: %@", appId);

          NSDictionary * dict = @{@"message":@"Bugly 初始化成功", @"isSuccess":@YES};
          NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
          NSString * json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
          
          result(json);
      }else{
          NSDictionary * dict = @{@"message":@"Bugly 初始化失败", @"isSuccess":@NO};
          NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
          NSString * json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
          
          result(json);
      }
      
  }else if([@"postException" isEqualToString:call.method]){
      NSString *type = call.arguments[@"type"];
      NSString *error = call.arguments[@"error"];
      NSString *stackTrace = call.arguments[@"stackTrace"];
      if (type == nil && error == nil) {
         error = @"";
      } else if (error == nil) {
        error = type;
      }
      if ([stackTrace isKindOfClass:[NSNull class]]) {
          stackTrace = @"";
      }
      NSException* ex = [[NSException alloc]initWithName:error
                                                  reason:stackTrace
                                                userInfo:nil];
      [Bugly reportException:ex];
      result(nil);
  }else if([@"setUserId" isEqualToString:call.method]){
      NSString *userId = call.arguments[@"userId"];
      if (![self isBlankString:userId]) {
          [Bugly setUserIdentifier:userId];
      }
      result(nil);
  }else if([@"setUserSceneTag" isEqualToString:call.method]){
      NSNumber *userSceneTag = call.arguments[@"userSceneTag"];
      if (userSceneTag!=nil) {
          NSInteger anInteger = [userSceneTag integerValue];
          [Bugly setTag:anInteger];
      }
      result(nil);
  }else if([@"putUserData" isEqualToString:call.method]){
      NSString *key = call.arguments[@"key"];
      NSString *value = call.arguments[@"value"];
      if (![self isBlankString:key]&&![self isBlankString:value]){
          [Bugly setUserValue:value forKey:key];
      }
      result(nil);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (BOOL) isBlankString:(NSString *)string {
    if (string == nil || string == NULL) {
        return YES;
    }
    
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
    
}

@end
