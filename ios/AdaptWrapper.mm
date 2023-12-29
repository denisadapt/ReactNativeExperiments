#import "AdaptWrapper.hh"
#import "mufl-bindings_ios.hh"

#define GET_OBJECT( name, cls, key ) \
  cls* name = [adaptStorage retrieveObjectForKey:key]; \
  if ( name == nil ) { \
    reject(@"AccessError", @"Object not found", nil); \
    return; \
  } else if ( ![name isKindOfClass:[cls class]] ) { \
    reject(@"AccessError", @"Object is not of the expected type", nil); \
    return; \
  }

#define CHECK_ERROR \
  if ( [AdaptEnvironment hasError] ) { \
    reject(@"", [AdaptEnvironment getError], nil); \
    return; \
  }

#define RESOLVE_OR_REJECT( ret ) \
  if ( [AdaptEnvironment hasError] ) { \
    reject(@"", [AdaptEnvironment getError], nil); \
  } else { \
    NSString* returnKey = [adaptStorage storeObject:ret]; \
    resolve(returnKey); \
  }

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
  BOOL init = [AdaptEnvironment Initialize:test_mode];
  resolve(@(init));
}

RCT_EXPORT_METHOD(AE_EmptyPacket:(BOOL)secure
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  AdaptPacketContext* packet = [AdaptEnvironment EmptyPacket:secure];
  RESOLVE_OR_REJECT( packet )
}

RCT_EXPORT_METHOD(AE_CreatePacket:(NSString*)unitKey
                  seed:(NSString*)seed
                  entropy:(NSString*)entropy
                  secure:(BOOL)secure
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  GET_OBJECT( unit, AdaptEvaluationUnit, unitKey )
  AdaptPacketContext* packet = [AdaptEnvironment CreatePacket:unit seed:seed entropy:entropy secure:secure];
  RESOLVE_OR_REJECT( packet )
}

RCT_EXPORT_METHOD(AE_SystemTime:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  AdaptValue* time = [AdaptEnvironment SystemTime];
  RESOLVE_OR_REJECT( time )
}

RCT_EXPORT_METHOD(AE_ParseTime:(NSString*)time
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  AdaptValue* value = [AdaptEnvironment ParseTime:time];
  RESOLVE_OR_REJECT( value )
}

RCT_EXPORT_METHOD(AE_GetRandomBytes:(int)length
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  AdaptValue* value = [AdaptEnvironment GetRandomBytes:length];
  RESOLVE_OR_REJECT( value )
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

RCT_EXPORT_METHOD(AE_clearError:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  [AdaptEnvironment clearError];
  resolve(nil);
}

RCT_EXPORT_METHOD(AV_FromString:(NSString *)value
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  AdaptValue* adaptValue = [AdaptValue FromString:value];
  RESOLVE_OR_REJECT( adaptValue )
}

RCT_EXPORT_METHOD(AV_FromNumber:(NSInteger)value
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  AdaptValue* adaptValue = [AdaptValue FromNumber:value];
  RESOLVE_OR_REJECT( adaptValue )
}

RCT_EXPORT_METHOD(AV_FromBoolean:(BOOL)value
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  AdaptValue* adaptValue = [AdaptValue FromBoolean:value];
  RESOLVE_OR_REJECT( adaptValue )
}

RCT_EXPORT_METHOD(AV_Reduce:(NSString *)key
                  v:(NSString *)v
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  GET_OBJECT( value, AdaptValue, key )
  GET_OBJECT( reducer, AdaptValue, v )
  AdaptValue* result = [value Reduce:reducer];
  RESOLVE_OR_REJECT( result )
}

RCT_EXPORT_METHOD(AV_Mutate:(NSString *)key
                  reducerKey:(NSString *)reducerKey
                    :(NSString *)productKey
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  GET_OBJECT( value, AdaptValue, key )
  GET_OBJECT(reducer, AdaptValue, reducerKey)
  GET_OBJECT(product, AdaptValue, productKey)
  AdaptValue* result = [value Mutate:reducer product:product];
  RESOLVE_OR_REJECT( result )
}

RCT_EXPORT_METHOD(AV_Visualize:(NSString *)key
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  GET_OBJECT( value, AdaptValue, key )
  NSString* result = [value Visualize];
  CHECK_ERROR
  resolve(result);
}

RCT_EXPORT_METHOD(AV_Serialize:(NSString *)key
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  GET_OBJECT( value, AdaptValue, key )
  NSData* result = [value Serialize];
  CHECK_ERROR
  resolve(result);
}


RCT_EXPORT_METHOD(AV_GetHash:(NSString *)key
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  GET_OBJECT( value, AdaptValue, key )
  AdaptValue* result = [value GetHash];
  RESOLVE_OR_REJECT( result )
}

RCT_EXPORT_METHOD(AV_GetPacket:(NSString *)key
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  GET_OBJECT( value, AdaptValue, key )
  AdaptPacketContext* result = [value GetPacket];
  RESOLVE_OR_REJECT( result )
}

RCT_EXPORT_METHOD(AV_GetNumber:(NSString *)key
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  GET_OBJECT( value, AdaptValue, key )
  NSInteger result = [value GetNumber];
  CHECK_ERROR
  resolve(@(result));
}

RCT_EXPORT_METHOD(AV_GetBoolean:(NSString *)key
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  GET_OBJECT( value, AdaptValue, key )
  BOOL result = [value GetBoolean];
  CHECK_ERROR
  resolve(@(result));
}

RCT_EXPORT_METHOD(AV_GetBinary:(NSString *)key
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  GET_OBJECT( value, AdaptValue, key )
  NSData* result = [value GetBinary];
  CHECK_ERROR
  resolve(result);
}

RCT_EXPORT_METHOD(AV_IsNil:(NSString *)key
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  GET_OBJECT( value, AdaptValue, key )
  BOOL result = [value IsNil];
  CHECK_ERROR
  resolve(@(result));
}

RCT_EXPORT_METHOD(AV_Equals:(NSString *)key
                  rhs:(NSString *)otherKey
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  GET_OBJECT( value, AdaptValue, key )
  GET_OBJECT( other, AdaptValue, otherKey )
  BOOL result = [value Equals:other];
  CHECK_ERROR
  resolve(@(result));
}

RCT_EXPORT_METHOD(AV_Less:(NSString *)key
                  rhs:(NSString *)otherKey
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  GET_OBJECT( value, AdaptValue, key )
  GET_OBJECT( other, AdaptValue, otherKey )
  BOOL result = [value Less:other];
  CHECK_ERROR
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
  RESOLVE_OR_REJECT( unit )
}

RCT_EXPORT_METHOD(AEU_LoadFromContents:(NSData*)bin
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  AdaptEvaluationUnit* unit = [AdaptEvaluationUnit LoadFromContents:bin];
  RESOLVE_OR_REJECT( unit )
}

RCT_EXPORT_METHOD(AEU_Clone:(NSString *)unitKey
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  GET_OBJECT( unit, AdaptEvaluationUnit, unitKey )
  AdaptEvaluationUnit* clone = [unit Clone];
  RESOLVE_OR_REJECT( clone )
}

RCT_EXPORT_METHOD(AEU_IsEmpty:(NSString *)unitKey
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  GET_OBJECT( unit, AdaptEvaluationUnit, unitKey )
  BOOL result = [unit IsEmpty];
  CHECK_ERROR
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
  GET_OBJECT( unit, AdaptEvaluationUnit, unitKey )
  [unit Check];
  CHECK_ERROR
  resolve(nil);
}

RCT_EXPORT_METHOD(APC_LoadFromFile:(NSString *)path
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  AdaptPacketContext* packet = [AdaptPacketContext LoadFromFile:path];
  RESOLVE_OR_REJECT( packet )
}

RCT_EXPORT_METHOD(APC_LoadFromContents:(NSData*)bin
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  AdaptPacketContext* packet = [AdaptPacketContext LoadFromContents:bin];
  RESOLVE_OR_REJECT( packet )
}

RCT_EXPORT_METHOD(APC_ParseValue:(NSString *)unitKey
                    :(NSString *)valueKey
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  GET_OBJECT( packet, AdaptPacketContext, unitKey )
  GET_OBJECT( value, AdaptValue, valueKey )
  AdaptValue* result = [packet ParseValue:value];
  RESOLVE_OR_REJECT( result )
}

RCT_EXPORT_METHOD(APC_ParseValueFromJSON:(NSString *)unitKey
                  json:(NSString *)json
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  GET_OBJECT( packet, AdaptPacketContext, unitKey )
  AdaptValue* result = [packet ParseValueFromJSON:json];
  RESOLVE_OR_REJECT( result )
}

RCT_EXPORT_METHOD(APC_CreateDictionary:(NSString *)unitKey
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  GET_OBJECT( packet, AdaptPacketContext, unitKey )
  AdaptValue* result = [packet CreateDictionary];
  RESOLVE_OR_REJECT( result )
}

RCT_EXPORT_METHOD(APC_NewBinaryFromHex:(NSString *)unitKey
                  hex:(NSString *)hex
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  GET_OBJECT( packet, AdaptPacketContext, unitKey )
  AdaptValue* result = [packet NewBinaryFromHex:hex];
  RESOLVE_OR_REJECT( result )
}

RCT_EXPORT_METHOD(APC_NewBinaryFromBuffer:(NSString *)unitKey
                    :(NSData *)data
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  GET_OBJECT( packet, AdaptPacketContext, unitKey )
  AdaptValue* result = [packet NewBinaryFromBuffer:data];
  RESOLVE_OR_REJECT( result )
}

RCT_EXPORT_METHOD(APC_ExecuteTransaction:(NSString *)unitKey
                  txKey:(NSString *)txKey
                  entropyHex:(NSString *)entropyHex
                  timestampKey:(NSString *)timestampKey
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  GET_OBJECT( packet, AdaptPacketContext, unitKey )
  GET_OBJECT( tx, AdaptValue, txKey )
  GET_OBJECT( timestamp, AdaptValue, timestampKey )
  [packet ExecuteTransaction:tx entropy_hex:entropyHex timestamp:timestamp];
  CHECK_ERROR
  resolve(nil);
}

RCT_EXPORT_METHOD(APC_TransactionsList:(NSString *)unitKey
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  GET_OBJECT( packet, AdaptPacketContext, unitKey )
  NSArray* result = [packet TransactionsList];
  CHECK_ERROR
  resolve(result);
}

RCT_EXPORT_METHOD(APC_GetFunction:(NSString *)unitKey
                  functionName:(NSString *)functionName
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  GET_OBJECT( packet, AdaptPacketContext, unitKey )
  AdaptFunctionInvocation* function = [packet GetFunction:functionName];
  RESOLVE_OR_REJECT( function )
}

RCT_EXPORT_METHOD(APC_NilObject:(NSString*)key
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  GET_OBJECT( value, AdaptPacketContext, key )
  AdaptValue* nilValue = [value NilObject];
  RESOLVE_OR_REJECT( nilValue )
}

RCT_EXPORT_METHOD(APC_GetHash:(NSString *)unitKey
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  GET_OBJECT( packet, AdaptPacketContext, unitKey )
  AdaptValue* hash = [packet GetHash];
  RESOLVE_OR_REJECT( hash )
}

RCT_EXPORT_METHOD(APC_Serialize:(NSString *)unitKey
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  GET_OBJECT( packet, AdaptPacketContext, unitKey )
  NSData* bin = [packet Serialize];
  CHECK_ERROR
  resolve(bin);
}

RCT_EXPORT_METHOD(APC_GetContainerID:(NSString *)unitKey
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  GET_OBJECT( packet, AdaptPacketContext, unitKey )
  AdaptValue* cid = [packet GetContainerID];
  RESOLVE_OR_REJECT( cid )
}

RCT_EXPORT_METHOD(APC_GetCodeID:(NSString *)unitKey
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  GET_OBJECT( packet, AdaptPacketContext, unitKey )
  AdaptValue* cid = [packet GetCodeID];
  RESOLVE_OR_REJECT( cid )
}

RCT_EXPORT_METHOD(APC_Clone:(NSString *)unitKey
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  GET_OBJECT( packet, AdaptPacketContext, unitKey )
  AdaptPacketContext* clone = [packet Clone];
  RESOLVE_OR_REJECT( clone )
}

RCT_EXPORT_METHOD(APC_Destroy:(NSString *)unitKey
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  [adaptStorage removeObjectForKey:unitKey];
  resolve(nil);
}

@end
