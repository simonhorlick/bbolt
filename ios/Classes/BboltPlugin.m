#import "BboltPlugin.h"

#import <Mobile/Mobile.h>

MobileBoltDB* db;

@implementation BboltPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    NSString* path = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,
                                                          NSUserDomainMask,
                                                          YES) objectAtIndex:0];
    NSError *err;
    db = MobileNewBoltDB(path, &err);
    if (err != nil) {
        NSLog(@"error opening db %@", [err localizedDescription]);
    }

    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"bbolt"
                                     binaryMessenger:[registrar messenger]];
    BboltPlugin* instance = [[BboltPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"get" isEqualToString:call.method]) {
      NSError *err;
      NSData *data = [db get:call.arguments[@"bucket"] key:call.arguments[@"key"] error:&err];
      if (err != nil) {
          result([FlutterError errorWithCode:@"error"
                                     message:[err localizedDescription]
                                     details:nil]);
          return;
      }
      result(data);
  } else if ([@"put" isEqualToString:call.method]) {
      FlutterStandardTypedData* value = call.arguments[@"value"];

      NSError *err;
      [db put:call.arguments[@"bucket"] key:call.arguments[@"key"] value:value.data error:&err];
      if (err != nil) {
          result([FlutterError errorWithCode:@"error"
                                     message:[err localizedDescription]
                                     details:nil]);
          return;
      }
      result(@(1));
  } else if ([@"getKeysByPrefix" isEqualToString:call.method]) {
      NSError *err;
      NSData *data = [db getKeysByPrefix:call.arguments[@"bucket"] prefix:call.arguments[@"prefix"] error:&err];
      if (err != nil) {
          result([FlutterError errorWithCode:@"error"
                                     message:[err localizedDescription]
                                     details:nil]);
          return;
      }
      result(data);
  } else if ([@"createBucketIfNotExists" isEqualToString:call.method]) {
      NSError *err;
      [db createBucketIfNotExists:call.arguments[@"bucket"] error:&err];
      if (err != nil) {
          result([FlutterError errorWithCode:@"error"
                                     message:[err localizedDescription]
                                     details:nil]);
          return;
      }
      result(@(1));
  } else {
      result(FlutterMethodNotImplemented);
  }
}

@end
