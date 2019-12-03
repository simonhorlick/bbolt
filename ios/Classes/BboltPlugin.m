#import "BboltPlugin.h"

#import <Mobile/Mobile.h>

MobileBoltDB* db;

@implementation BboltPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  NSString* path = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,
                                                          NSUserDomainMask,
                                                          YES) objectAtIndex:0];
  db = MobileNewBoltDB(path);
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"bbolt"
            binaryMessenger:[registrar messenger]];
  BboltPlugin* instance = [[BboltPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  // Call through to the gomobile generated bindings.
  if ([@"getKey" isEqualToString:call.method]) {
      result([db getKey:call.arguments[@"bucket"] key:call.arguments[@"key"]]);
  } else if ([@"putKey" isEqualToString:call.method]) {
      NSString* bucket = call.arguments[@"bucket"];
      NSString* key = call.arguments[@"key"];
      FlutterStandardTypedData* value = call.arguments[@"value"];
      [db putKey:bucket key:key value:value.data];
      if (false) {
          result([FlutterError errorWithCode:@"UNAVAILABLE"
                                     message:@"Battery info unavailable"
                                     details:nil]);
      }
    result(@(1));
  } else if ([@"createBucketIfNotExists" isEqualToString:call.method]) {
      NSString* bucket = call.arguments[@"bucket"];
      [db createBucketIfNotExists:bucket];
      result(@(1));
  } else {
      result(FlutterMethodNotImplemented);
  }
}

@end
