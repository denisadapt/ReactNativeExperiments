#import "MyLibraryWrapper.hh"
#include "mylibrary.hh"

@implementation MyLibraryWrapper

RCT_EXPORT_MODULE(); // Expose this module to React Native

RCT_EXPORT_METHOD(greet:(NSString *)name
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
//    @try {
        std::string stdName = [name UTF8String];
        std::string greeting = greet(stdName);
        resolve(@(greeting.c_str()));
//    }
//    @catch (const std::exception &e) {
//        reject(@"greet_failure", @"Failed to greet", nil);
//    }
}

RCT_EXPORT_METHOD(add:(NSInteger)a
                  b:(NSInteger)b
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
//    @try {
        int result = add(static_cast<int>(a), static_cast<int>(b));
        resolve(@(result));
//    }
//    @catch (const std::exception &e) {
//        reject(@"add_failure", @"Failed to add", nil);
//    }
}

RCT_EXPORT_METHOD(readFileContents:(NSString *)path
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  const char* cPath = [path UTF8String];
  std::string contents = readFileContent(cPath);
    resolve(@(contents.c_str()));
}

@end
