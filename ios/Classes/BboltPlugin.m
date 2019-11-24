#import "BboltPlugin.h"

#import <Mobile/Mobile.h>

@implementation BboltPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"bbolt"
            binaryMessenger:[registrar messenger]];
  BboltPlugin* instance = [[BboltPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  // TODO(simon): Call through to the gomobile generated bindings.
  if ([@"getPlatformVersion" isEqualToString:call.method]) {  
    NSString* path = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,
                                                          NSUserDomainMask,
                                                          YES) objectAtIndex:0];
    MobileBoltDB* demo = MobileNewBoltDB(path);
    // TODO(simon): ...
    [demo close];

    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
