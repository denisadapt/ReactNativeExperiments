#import "AdaptWrapper.hh"
#import "mufl-bindings_ios.hh"

@interface ObjectStorage : NSObject
- (NSString *)storeObject:(id)object;
- (id)retrieveObjectForKey:(NSString *)key;
- (void)removeObjectForKey:(NSString *)key;
@end

// Implementation of ObjectStorage
@implementation ObjectStorage {
    NSMutableDictionary *objectMap;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        objectMap = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (NSString *)storeObject:(id)object {
    NSString *key = [NSString stringWithFormat:@"%p", object];
    objectMap[key] = object;
    return key;
}

- (id)retrieveObjectForKey:(NSString *)key {
    return objectMap[key];
}

- (void)removeObjectForKey:(NSString *)key {
    [objectMap removeObjectForKey:key];
}

@end

static ObjectStorage *adaptStorage = nil;

// Initialize the static instance
__attribute__((constructor))
static void initializeAdaptStorage() {
    adaptStorage = [[ObjectStorage alloc] init];
}

@implementation AdaptWrapper

RCT_EXPORT_MODULE(AdaptWrapper); // Expose this module to React Native

RCT_EXPORT_METHOD(AE_Initialize:(BOOL)test_mode
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
//    @try {
  BOOL init = [AdaptEnvironment Initialize:test_mode];
  resolve(@(init));
//  if (init) {
//    resolve(@"Adapt init success");
//  }
//  else {
//    AdaptValue* time = [AdaptEnvironment SystemTime];
//    NSString* systemTime = [time Visualize];
//    resolve(systemTime);
////    resolve([MyLibrary greet:name]);
//  }
//    }
//    @catch (const std::exception &e) {
//        reject(@"greet_failure", @"Failed to greet", nil);
//    }
}

RCT_EXPORT_METHOD(AE_hasError:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  BOOL hasError = [AdaptEnvironment hasError];
  resolve(@(hasError));
}

RCT_EXPORT_METHOD(AE_getError:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  NSString *error = [AdaptEnvironment getError];
  resolve(error);
}

RCT_EXPORT_METHOD(AE_SystemTime:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  AdaptValue* time = [AdaptEnvironment SystemTime];
  NSString* key = [adaptStorage storeObject:time];
  resolve(key);
}

RCT_EXPORT_METHOD(AV_Visualize:(NSString *)key
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  AdaptValue* value = [adaptStorage retrieveObjectForKey:key];
  NSString* result = [value Visualize];
  resolve(result);
}

@end
