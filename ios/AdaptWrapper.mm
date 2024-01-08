#import "AdaptWrapper.hh"
#import "mufl-bindings_ios.hh"

#define GET_OBJECT_OR_E_RETURN( name, cls, key ) \
  cls* name = [adaptStorage retrieveObjectForKey:key]; \
  if (name == nil) { \
    [AdaptEnvironment setError:[NSString stringWithFormat:@"Couldn't find object by key %@", key]]; \
    return @""; \
  }

#define AV_EMPTY @{ @"address": @"", @"_type": @"AdaptValue" }
#define APC_EMPTY @{ @"address": @"", @"_type": @"AdaptPacketContext" }
#define AEU_EMPTY @{ @"address": @"", @"_type": @"AdaptEvaluationUnit" }
#define AFI_EMPTY @{ @"address": @"", @"_type": @"AdaptFunctionInvocation" }

#define GET_OBJECT_OR_E_RETURN_NEW( NAME, CLS, KEY, RET ) \
  if (![KEY[@"address"] isKindOfClass:[NSString class]] || ![KEY[@"_type"] isKindOfClass:[NSString class]]) { \
    [AdaptEnvironment setError:@"Invalid key format"]; \
    return RET; \
  } \
  if (![KEY[@"_type"] isEqualToString: NSStringFromClass([CLS class])]) { \
    [AdaptEnvironment setError:@"Invalid type"]; \
    return RET; \
  } \
  CLS* NAME = [adaptStorage retrieveObjectForKey:KEY[@"address"]]; \
  if (NAME == nil) { \
    [AdaptEnvironment setError:[NSString stringWithFormat:@"Couldn't find object by key %@", KEY[@"address"]]]; \
    return RET; \
  }

#define STORE_AND_RETURN_NEW( ret, type ) \
  return @{ @"address": [adaptStorage storeObject:ret], @"_type": type };

#define AV_STORE_AND_RETURN( ret ) STORE_AND_RETURN_NEW( ret, @"AdaptValue" )
#define APC_STORE_AND_RETURN( ret ) STORE_AND_RETURN_NEW( ret, @"AdaptPacketContext" )
#define AEU_STORE_AND_RETURN( ret ) STORE_AND_RETURN_NEW( ret, @"AdaptEvaluationUnit" )
#define AFI_STORE_AND_RETURN( ret ) STORE_AND_RETURN_NEW( ret, @"AdaptFunctionInvocation" )

#define STORE_AND_RETURN( ret ) return [adaptStorage storeObject:ret];

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

RCT_EXPORT_MODULE(AdaptWrapperNative); // Expose this module to React Native

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD
 (AE_Initialize:(BOOL)test_mode)
{
  return @([AdaptEnvironment Initialize:test_mode]);
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD
 (AE_EmptyPacket:(BOOL)secure)
{
  AdaptPacketContext* packet = [AdaptEnvironment EmptyPacket:secure];
  APC_STORE_AND_RETURN( packet )
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD
 (AE_CreatePacket:(NSDictionary*)unitKey
                  seed:(NSString*)seed
                  entropy:(NSString*)entropy
                  secure:(BOOL)secure)
{
  GET_OBJECT_OR_E_RETURN_NEW( unit, AdaptEvaluationUnit, unitKey, APC_EMPTY )
  AdaptPacketContext* packet = [AdaptEnvironment CreatePacket:unit seed:seed entropy:entropy secure:secure];
  APC_STORE_AND_RETURN( packet )
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD
 (AE_SystemTime)
{
  AdaptValue* time = [AdaptEnvironment SystemTime];
  AV_STORE_AND_RETURN( time )
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD
 (AE_SystemTimeNew)
{
  AdaptValue* time = [AdaptEnvironment SystemTime];
  AV_STORE_AND_RETURN( time )
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD
 (AE_ParseTime:(NSString*)time)
{
  AdaptValue* value = [AdaptEnvironment ParseTime:time];
  AV_STORE_AND_RETURN( value )
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD
 (AE_GetRandomBytes:(int)length)
{
  AdaptValue* value = [AdaptEnvironment GetRandomBytes:length];
  AV_STORE_AND_RETURN( value )
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD
 (AE_hasError)
{
  return @([AdaptEnvironment hasError]);
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD
 (AE_getError)
{
  return [AdaptEnvironment getError];
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD
 (AE_clearError)
{
  [AdaptEnvironment clearError];
  return @"";
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD
 (AV_FromString:(NSString *)value) {
  AdaptValue* adaptValue = [AdaptValue FromString:value];
  AV_STORE_AND_RETURN( adaptValue )
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD
 (AV_FromNumber:(NSInteger)value)
{
  AdaptValue* adaptValue = [AdaptValue FromNumber:value];
  AV_STORE_AND_RETURN( adaptValue )
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD
 (AV_FromBoolean:(BOOL)value) {
  AdaptValue* adaptValue = [AdaptValue FromBoolean:value];
  AV_STORE_AND_RETURN( adaptValue )
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD
 (AV_Reduce:(NSDictionary *)key v:(NSDictionary *)v)
{
  GET_OBJECT_OR_E_RETURN_NEW( value, AdaptValue, key, AV_EMPTY )
  GET_OBJECT_OR_E_RETURN_NEW( reducer, AdaptValue, v, AV_EMPTY )
  AdaptValue* result = [value Reduce:reducer];
  AV_STORE_AND_RETURN( result )
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD
 (AV_Mutate:(NSDictionary *)key reducerKey:(NSDictionary *)reducerKey productKey:(NSDictionary *)productKey)
{
  GET_OBJECT_OR_E_RETURN_NEW( value, AdaptValue, key, AV_EMPTY )
  GET_OBJECT_OR_E_RETURN_NEW(reducer, AdaptValue, reducerKey, AV_EMPTY )
  GET_OBJECT_OR_E_RETURN_NEW(product, AdaptValue, productKey, AV_EMPTY )
  AdaptValue* result = [value Mutate:reducer product:product];
  AV_STORE_AND_RETURN( result )
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD
 (AV_Visualize:(NSDictionary *)key)
{
  GET_OBJECT_OR_E_RETURN_NEW( value, AdaptValue, key, @"" )
  return [value Visualize];
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD
 (AV_VisualizeNew:(NSDictionary*)key)
{
//  if (![key[@"address"] isKindOfClass:[NSString class]] || ![key[@"_type"] isKindOfClass:[NSString class]]) {
//    [AdaptEnvironment setError:@"Invalid key format"];
//    return @"";
//  }
//  if (![key[@"_type"] isEqualToString: NSStringFromClass([AdaptValue class])]) {
//    [AdaptEnvironment setError:@"Invalid type"];
////    [AdaptEnvironment setError:[NSString stringWithFormat:@"Expected object of type %@, but got %@", NSStringFromClass([AdaptValue class]), ]];
//    return @"";
//  }
//  AdaptValue* value = [adaptStorage retrieveObjectForKey:key[@"address"]];
//  if (!value) {
//    [AdaptEnvironment setError:[NSString stringWithFormat:@"Couldn't find object by key %@", key[@"address"]]];
//    return @"";
//  }
  GET_OBJECT_OR_E_RETURN_NEW( value, AdaptValue, key, @"" )
  return [value Visualize];
//  AdaptValue* value = [adaptStorage getObject:[key objectForKey:@"address"]];
  
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD
 (AV_Serialize:(NSDictionary *)key)
{
  GET_OBJECT_OR_E_RETURN_NEW( value, AdaptValue, key, [NSData new] )
  return [value Serialize];
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD
 (AV_GetHash:(NSDictionary *)key) {
  GET_OBJECT_OR_E_RETURN_NEW( value, AdaptValue, key, AV_EMPTY )
  AdaptValue* result = [value GetHash];
  AV_STORE_AND_RETURN( result )
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD
 (AV_GetPacket:(NSDictionary *)key)
{
  GET_OBJECT_OR_E_RETURN_NEW( value, AdaptValue, key, APC_EMPTY )
  AdaptPacketContext* result = [value GetPacket];
  APC_STORE_AND_RETURN( result )
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD
 (AV_GetNumber:(NSDictionary *)key) {
  GET_OBJECT_OR_E_RETURN_NEW( value, AdaptValue, key, @(-1) )
  return @([value GetNumber]);
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD
 (AV_GetBoolean:(NSDictionary *)key)
{
  GET_OBJECT_OR_E_RETURN_NEW( value, AdaptValue, key, @(NO) )
  return @([value GetBoolean]);
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD
 (AV_GetBinary:(NSDictionary *)key) {
  GET_OBJECT_OR_E_RETURN_NEW( value, AdaptValue, key, [NSData new] )
  return [value GetBinary];
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(AV_IsNil:(NSDictionary *)key) {
  GET_OBJECT_OR_E_RETURN_NEW( value, AdaptValue, key, @(YES) )
  return @([value IsNil]);
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD
 (AV_Equals:(NSDictionary *)key rhs:(NSDictionary *)otherKey)
{
  GET_OBJECT_OR_E_RETURN_NEW( value, AdaptValue, key, @(NO) )
  GET_OBJECT_OR_E_RETURN_NEW( other, AdaptValue, otherKey, @(NO) )
  return @([value Equals:other]);
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD
 (AV_Less:(NSDictionary *)key rhs:(NSDictionary *)otherKey)
{
  GET_OBJECT_OR_E_RETURN_NEW( value, AdaptValue, key, @(NO) )
  GET_OBJECT_OR_E_RETURN_NEW( other, AdaptValue, otherKey, @(NO) )
  return @([value Less:other]);
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD
 (AV_Destroy:(NSDictionary *)key)
{
  [adaptStorage removeObjectForKey:key[@"address"]];  // TODO
  return @"";
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD
 (AEU_LoadFromFile:(NSString *)path) {
  AdaptEvaluationUnit* unit = [AdaptEvaluationUnit LoadFromFile:path];
  AEU_STORE_AND_RETURN( unit )
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD
 (AEU_LoadFromContents:(NSData*)bin)
{
  AdaptEvaluationUnit* unit = [AdaptEvaluationUnit LoadFromContents:bin];
  AEU_STORE_AND_RETURN( unit )
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD
 (AEU_Clone:(NSDictionary *)unitKey)
{
  GET_OBJECT_OR_E_RETURN_NEW( unit, AdaptEvaluationUnit, unitKey, AEU_EMPTY )
  AdaptEvaluationUnit* clone = [unit Clone];
  AEU_STORE_AND_RETURN( clone )
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD
 (AEU_IsEmpty:(NSDictionary *)unitKey)
{
  GET_OBJECT_OR_E_RETURN_NEW( unit, AdaptEvaluationUnit, unitKey, @(YES) )
  return @([unit IsEmpty]);
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD
 (AEU_Destroy:(NSDictionary *)unitKey)
{
  [adaptStorage removeObjectForKey:unitKey[@"address"]];  // TODO
  return @"";
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD
 (AEU_Check:(NSDictionary *)unitKey)
{
  GET_OBJECT_OR_E_RETURN_NEW( unit, AdaptEvaluationUnit, unitKey, @"" )
  [unit Check];
  return @"";
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD
 (APC_LoadFromFile:(NSString *)path)
{
  AdaptPacketContext* packet = [AdaptPacketContext LoadFromFile:path];
  APC_STORE_AND_RETURN( packet )
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD
 (APC_LoadFromContents:(NSData*)bin)
{
  AdaptPacketContext* packet = [AdaptPacketContext LoadFromContents:bin];
  APC_STORE_AND_RETURN( packet )
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD
 (APC_ParseValue:(NSDictionary *)unitKey
                val:(NSDictionary *)valueKey)
{
  GET_OBJECT_OR_E_RETURN_NEW( packet, AdaptPacketContext, unitKey, AV_EMPTY )
  GET_OBJECT_OR_E_RETURN_NEW( value, AdaptValue, valueKey, AV_EMPTY )
  AdaptValue* result = [packet ParseValue:value];
  AV_STORE_AND_RETURN( result )
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD
 (APC_ParseValueFromJSON:(NSDictionary *)unitKey json:(NSString *)json)
{
  GET_OBJECT_OR_E_RETURN_NEW( packet, AdaptPacketContext, unitKey, AV_EMPTY )
  AdaptValue* result = [packet ParseValueFromJSON:json];
  AV_STORE_AND_RETURN( result )
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD
 (APC_CreateDictionary:(NSDictionary *)unitKey)
{
  GET_OBJECT_OR_E_RETURN_NEW( packet, AdaptPacketContext, unitKey, AV_EMPTY )
  AdaptValue* result = [packet CreateDictionary];
  AV_STORE_AND_RETURN( result )
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD
 (APC_NewBinaryFromHex:(NSDictionary *)unitKey hex:(NSString *)hex)
{
  GET_OBJECT_OR_E_RETURN_NEW( packet, AdaptPacketContext, unitKey, AV_EMPTY )
  AdaptValue* result = [packet NewBinaryFromHex:hex];
  AV_STORE_AND_RETURN( result )
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD
 (APC_NewBinaryFromBuffer:(NSDictionary *)unitKey data:(NSData *)data)
{
  GET_OBJECT_OR_E_RETURN_NEW( packet, AdaptPacketContext, unitKey, AV_EMPTY )
  AdaptValue* result = [packet NewBinaryFromBuffer:data];
  AV_STORE_AND_RETURN( result )
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD
 (APC_ExecuteTransaction:(NSDictionary *)unitKey
                   txKey:(NSDictionary *)txKey
              entropyHex:(NSString *)entropyHex
            timestampKey:(NSDictionary *)timestampKey)
{
  GET_OBJECT_OR_E_RETURN_NEW( packet, AdaptPacketContext, unitKey, @"" )
  GET_OBJECT_OR_E_RETURN_NEW( tx, AdaptValue, txKey, @"" )
  GET_OBJECT_OR_E_RETURN_NEW( timestamp, AdaptValue, timestampKey, @"" )
  [packet ExecuteTransaction:tx entropy_hex:entropyHex timestamp:timestamp];
  return @"";
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD
 (APC_TransactionsList:(NSDictionary *)unitKey)
{
  GET_OBJECT_OR_E_RETURN_NEW( packet, AdaptPacketContext, unitKey, @[] )
  return [packet TransactionsList];
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD
 (APC_GetFunction:(NSDictionary *)unitKey
     functionName:(NSString *)functionName)
{
  GET_OBJECT_OR_E_RETURN_NEW( packet, AdaptPacketContext, unitKey, AFI_EMPTY )
  AdaptFunctionInvocation* function = [packet GetFunction:functionName];
  AFI_STORE_AND_RETURN( function )
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD
 (APC_NilObject:(NSDictionary*)key)
{
  GET_OBJECT_OR_E_RETURN_NEW( value, AdaptPacketContext, key, AV_EMPTY )
  AdaptValue* nilValue = [value NilObject];
  AV_STORE_AND_RETURN( nilValue )
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD
 (APC_GetHash:(NSDictionary *)unitKey)
{
  GET_OBJECT_OR_E_RETURN_NEW( packet, AdaptPacketContext, unitKey, AV_EMPTY )
  AdaptValue* hash = [packet GetHash];
  AV_STORE_AND_RETURN( hash )
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD
 (APC_Serialize:(NSDictionary *)unitKey)
{
  GET_OBJECT_OR_E_RETURN_NEW( packet, AdaptPacketContext, unitKey, @[] )
  return [packet Serialize];
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD
 (APC_GetContainerID:(NSDictionary *)unitKey)
{
  GET_OBJECT_OR_E_RETURN_NEW( packet, AdaptPacketContext, unitKey, AV_EMPTY )
  AdaptValue* cid = [packet GetContainerID];
  AV_STORE_AND_RETURN( cid )
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD
 (APC_GetCodeID:(NSDictionary *)unitKey)
{
  GET_OBJECT_OR_E_RETURN_NEW( packet, AdaptPacketContext, unitKey, AV_EMPTY )
  AdaptValue* cid = [packet GetCodeID];
  AV_STORE_AND_RETURN( cid )
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD
 (APC_Clone:(NSDictionary *)unitKey)
{
  GET_OBJECT_OR_E_RETURN_NEW( packet, AdaptPacketContext, unitKey, APC_EMPTY )
  AdaptPacketContext* clone = [packet Clone];
  APC_STORE_AND_RETURN( clone )
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD
 (APC_Destroy:(NSString *)unitKey)
{
  [adaptStorage removeObjectForKey:unitKey];
  return @"";
}

@end
