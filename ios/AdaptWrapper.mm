#import "AdaptWrapper.hh"
#import "MyLibrary.hh"
#import "mufl-bindings_ios.hh"

@implementation AdaptWrapper

RCT_EXPORT_MODULE(); // Expose this module to React Native

RCT_EXPORT_METHOD(greet:(NSString *)name
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
//    @try {
  bool init = [AdaptEnvironment Initialize:true];
  if (init) {
    resolve(@"Adapt init success");
  }
  else {
    AdaptValue* time = [AdaptEnvironment SystemTime];
    NSString* systemTime = [time Visualize];
    resolve(systemTime);
//    resolve([MyLibrary greet:name]);
  }
//    }
//    @catch (const std::exception &e) {
//        reject(@"greet_failure", @"Failed to greet", nil);
//    }
}

RCT_EXPORT_METHOD(add:(NSInteger)a
                  b:(NSInteger)b
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {

  NSInteger result = [MyLibrary add:a with:b];
        resolve(@(result));
}

RCT_EXPORT_METHOD(readFileContents:(NSString *)path
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    resolve([MyLibrary readFileContent:path]);
}

@end
