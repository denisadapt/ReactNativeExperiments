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

RCT_EXPORT_METHOD(AE_EmptyPacket:(BOOL)secure
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  AdaptPacketContext* packet = [AdaptEnvironment EmptyPacket:secure];
  NSString* key = [adaptStorage storeObject:packet];
  resolve(key);
}

RCT_EXPORT_METHOD(AE_CreatePacket:(NSString*)unitKey
                  seed:(NSString*)seed
                  entropy:(NSString*)entropy
                  secure:(BOOL)secure
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  AdaptEvaluationUnit* unit = [adaptStorage retrieveObjectForKey:unitKey];
  AdaptPacketContext* packet = [AdaptEnvironment CreatePacket:unit seed:seed entropy:entropy secure:secure];
  NSString* key = [adaptStorage storeObject:packet];
  resolve(key);
}

RCT_EXPORT_METHOD(AE_SystemTime:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  AdaptValue* time = [AdaptEnvironment SystemTime];
  NSString* key = [adaptStorage storeObject:time];
  resolve(key);
}

RCT_EXPORT_METHOD(AE_ParseTime:(NSString*)time
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  AdaptValue* value = [AdaptEnvironment ParseTime:time];
  NSString* key = [adaptStorage storeObject:value];
  resolve(key);
}

RCT_EXPORT_METHOD(AE_GetRandomBytes:(int)length
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  AdaptValue* value = [AdaptEnvironment GetRandomBytes:length];
  NSString* key = [adaptStorage storeObject:value];
  resolve(key);
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

RCT_EXPORT_METHOD(AE_ClearError:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  [AdaptEnvironment clearError];
  resolve(nil);
}

RCT_EXPORT_METHOD(AV_Visualize:(NSString *)key
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  AdaptValue* value = [adaptStorage retrieveObjectForKey:key];
  NSString* result = [value Visualize];
  resolve(result);
}

RCT_EXPORT_METHOD(AV_GetNumber:(NSString *)key
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  AdaptValue* value = [adaptStorage retrieveObjectForKey:key];
  NSInteger result = [value GetNumber];
  resolve(@(result));
}

RCT_EXPORT_METHOD(AV_GetBoolean:(NSString *)key
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  AdaptValue* value = [adaptStorage retrieveObjectForKey:key];
  BOOL result = [value GetBoolean];
  resolve(@(result));
}

RCT_EXPORT_METHOD(AV_GetBinary:(NSString *)key
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  AdaptValue* value = [adaptStorage retrieveObjectForKey:key];
  NSData* result = [value GetBinary];
  resolve(result);
}

RCT_EXPORT_METHOD(AV_IsNil:(NSString *)key
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  AdaptValue* value = [adaptStorage retrieveObjectForKey:key];
  BOOL result = [value IsNil];
  resolve(@(result));
}

RCT_EXPORT_METHOD(AV_Equals:(NSString *)key
                  other:(NSString *)otherKey
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  AdaptValue* value = [adaptStorage retrieveObjectForKey:key];
  AdaptValue* other = [adaptStorage retrieveObjectForKey:otherKey];
  BOOL result = [value Equals:other];
  resolve(@(result));
}

RCT_EXPORT_METHOD(AV_Less:(NSString *)key
                  other:(NSString *)otherKey
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  AdaptValue* value = [adaptStorage retrieveObjectForKey:key];
  AdaptValue* other = [adaptStorage retrieveObjectForKey:otherKey];
  BOOL result = [value Less:other];
  resolve(@(result));
}

RCT_EXPORT_METHOD(AV_Destroy:(NSString *)key
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  [adaptStorage removeObjectForKey:key];
  resolve(nil);
}

RCT_EXPORT_METHOD(AEU_LoadFromFile:(NSString *)path
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  AdaptEvaluationUnit* unit = [AdaptEvaluationUnit LoadFromFile:path];
  NSString* key = [adaptStorage storeObject:unit];
  resolve(key);
}

RCT_EXPORT_METHOD(AEU_LoadFromContents:(NSData*)bin
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  AdaptEvaluationUnit* unit = [AdaptEvaluationUnit LoadFromContents:bin];
  NSString* key = [adaptStorage storeObject:unit];
  resolve(key);
}

RCT_EXPORT_METHOD(AEU_Clone:(NSString *)unitKey
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  AdaptEvaluationUnit* unit = [adaptStorage retrieveObjectForKey:unitKey];
  AdaptEvaluationUnit* clone = [unit Clone];
  NSString* key = [adaptStorage storeObject:clone];
  resolve(key);
}

RCT_EXPORT_METHOD(AEU_IsEmpty:(NSString *)unitKey
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  AdaptEvaluationUnit* unit = [adaptStorage retrieveObjectForKey:unitKey];
  BOOL result = [unit IsEmpty];
  resolve(@(result));
}

RCT_EXPORT_METHOD(AEU_Destroy:(NSString *)unitKey
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  [adaptStorage removeObjectForKey:unitKey];
  resolve(nil);
}

RCT_EXPORT_METHOD(AEU_Check:(NSString *)unitKey
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  AdaptEvaluationUnit* unit = [adaptStorage retrieveObjectForKey:unitKey];
  [unit Check];
  resolve(nil);
}

RCT_EXPORT_METHOD(APC_LoadFromFile:(NSString *)path
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  AdaptPacketContext* packet = [AdaptPacketContext LoadFromFile:path];
  NSString* key = [adaptStorage storeObject:packet];
  resolve(key);
}

RCT_EXPORT_METHOD(APC_LoadFromContents:(NSData*)bin
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  AdaptPacketContext* packet = [AdaptPacketContext LoadFromContents:bin];
  NSString* key = [adaptStorage storeObject:packet];
  resolve(key);
}

RCT_EXPORT_METHOD(APC_ParseValue:(NSString *)unitKey
                  valueKey:(NSString *)valueKey
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  AdaptPacketContext* packet = [adaptStorage retrieveObjectForKey:unitKey];
  AdaptValue* value = [adaptStorage retrieveObjectForKey:valueKey];
  AdaptValue* result = [packet ParseValue:value];
  NSString* key = [adaptStorage storeObject:result];
  resolve(key);
}

RCT_EXPORT_METHOD(APC_ParseValueFromJSON:(NSString *)unitKey
                  json:(NSString *)json
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  AdaptPacketContext* packet = [adaptStorage retrieveObjectForKey:unitKey];
  AdaptValue* result = [packet ParseValueFromJSON:json];
  NSString* key = [adaptStorage storeObject:result];
  resolve(key);
}

RCT_EXPORT_METHOD(APC_CreateDictionary:(NSString *)unitKey
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  AdaptPacketContext* packet = [adaptStorage retrieveObjectForKey:unitKey];
  AdaptValue* result = [packet CreateDictionary];
  NSString* key = [adaptStorage storeObject:result];
  resolve(key);
}

RCT_EXPORT_METHOD(APC_NewBinaryFromHex:(NSString *)unitKey
                  hex:(NSString *)hex
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  AdaptPacketContext* packet = [adaptStorage retrieveObjectForKey:unitKey];
  AdaptValue* result = [packet NewBinaryFromHex:hex];
  resolve(result);
}

RCT_EXPORT_METHOD(APC_NewBinaryFromBuffer:(NSString *)unitKey
                  data:(NSData *)data
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  AdaptPacketContext* packet = [adaptStorage retrieveObjectForKey:unitKey];
  AdaptValue* result = [packet NewBinaryFromBuffer:data];
  resolve(result);
}

RCT_EXPORT_METHOD(APC_ExecuteTransaction:(NSString *)unitKey
                  txKey:(NSString *)txKey
                  entropyHex:(NSString *)entropyHex
                  timestampKey:(NSString *)timestampKey
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  AdaptPacketContext* packet = [adaptStorage retrieveObjectForKey:unitKey];
  AdaptValue* tx = [adaptStorage retrieveObjectForKey:txKey];
  AdaptValue* timestamp = [adaptStorage retrieveObjectForKey:timestampKey];
  [packet ExecuteTransaction:tx entropy_hex:entropyHex timestamp:timestamp];
  resolve(nil);
}

RCT_EXPORT_METHOD(APC_GetHash:(NSString *)unitKey
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  AdaptPacketContext* packet = [adaptStorage retrieveObjectForKey:unitKey];
  AdaptValue* hash = [packet GetHash];
  NSString* key = [adaptStorage storeObject:hash];
  resolve(key);
}

RCT_EXPORT_METHOD(APC_Serialize:(NSString *)unitKey
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  AdaptPacketContext* packet = [adaptStorage retrieveObjectForKey:unitKey];
  NSData* bin = [packet Serialize];
  resolve(bin);
}

RCT_EXPORT_METHOD(APC_GetContainerID:(NSString *)unitKey
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  AdaptPacketContext* packet = [adaptStorage retrieveObjectForKey:unitKey];
  AdaptValue* cid = [packet GetContainerID];
  NSString* key = [adaptStorage storeObject:cid];
  resolve(key);
}

RCT_EXPORT_METHOD(APC_GetCodeID:(NSString *)unitKey
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  AdaptPacketContext* packet = [adaptStorage retrieveObjectForKey:unitKey];
  AdaptValue* cid = [packet GetCodeID];
  NSString* key = [adaptStorage storeObject:cid];
  resolve(key);
}

RCT_EXPORT_METHOD(APC_Clone:(NSString *)unitKey
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  AdaptPacketContext* packet = [adaptStorage retrieveObjectForKey:unitKey];
  AdaptPacketContext* clone = [packet Clone];
  NSString* key = [adaptStorage storeObject:clone];
  resolve(key);
}

RCT_EXPORT_METHOD(APC_Destroy:(NSString *)unitKey
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  [adaptStorage removeObjectForKey:unitKey];
  resolve(nil);
}

@end
