#pragma once

#import <Foundation/Foundation.h>

@class AdaptPacketContext;

@class AdaptValueImpl;
@class AdaptEvaluationUnitImpl;
@class AdaptPacketContextImpl;
@class AdaptFunctionInvocationImpl;

@interface AdaptValue : NSObject {
    AdaptValueImpl* impl;
}
- (instancetype)init;
+ (AdaptValue*)FromString:(NSString*)value;
+ (AdaptValue*)FromNumber:(NSInteger)value;
+ (AdaptValue*)FromBoolean:(BOOL)value;
- (AdaptValue*)Reduce:(AdaptValue*)v;
- (AdaptValue*)Mutate:(AdaptValue*)reducer product:(AdaptValue*)product;
- (AdaptValue*)GetHash;
- (AdaptPacketContext*)GetPacket;
- (NSString*)Visualize;
- (NSData*)Serialize;
- (NSInteger)GetNumber;
- (BOOL)GetBoolean;
- (AdaptValueImpl*)getImpl;
- (NSData*)GetBinary;
- (BOOL)IsNil;
- (BOOL)Equals:(AdaptValue*)rhs;
- (BOOL)Less:(AdaptValue*)rhs;
- (void)Destroy;
- (void)dealloc;
@end

@interface AdaptEvaluationUnit : NSObject {
    AdaptEvaluationUnitImpl* impl;
}
- (instancetype)init;
- (instancetype)initWithUnit:(AdaptEvaluationUnit*)unit;
- (AdaptEvaluationUnitImpl*)getImpl;
+ (AdaptEvaluationUnit*)LoadFromFile:(NSString*)filename;
+ (AdaptEvaluationUnit*)LoadFromContents:(NSData*)bin;
- (AdaptEvaluationUnit*)Clone;
- (BOOL)IsEmpty;
- (void)Destroy;
- (void)Check;
- (void)dealloc;
@end

@interface AdaptFunctionInvocation : NSObject {
    AdaptFunctionInvocationImpl* impl;
}
- (instancetype)init;
- (AdaptFunctionInvocationImpl*)getImpl;
- (void)Reset;
- (void)PushParameter:(AdaptValue*)value;
- (AdaptValue*)Execute;
- (bool)IsEmpty;
- (void)Destroy;
- (void)Check;
- (void)dealloc;
@end

@interface AdaptPacketContext : NSObject {
    AdaptPacketContextImpl* impl;
}
- (instancetype)init;
- (instancetype)initWithContext:(AdaptPacketContext*)context;
+ (AdaptPacketContext*)LoadFromFile:(NSString*)filename;
+ (AdaptPacketContext*)LoadFromContents:(NSData*)bin;

- (AdaptValue*)ParseValue:(AdaptValue*)source;
- (AdaptValue*)ParseValueFromJSON:(NSString*)json;
- (AdaptValue*)CreateDictionary;
- (AdaptValue*)NewBinaryFromHex:(NSString*)hex;
- (AdaptValue*)NewBinaryFromBuffer:(NSData*)data;
- (AdaptValue*)ExecuteTransaction:(AdaptValue*)transaction entropy_hex:(NSString*)entropy_hex timestamp:(AdaptValue*)timestamp;
- (AdaptFunctionInvocation*)GetFunction:(NSString*)functionName;
- (AdaptValue*)GetHash;
- (NSData*)Serialize;
- (AdaptValue*)GetContainerID;
- (AdaptValue*)GetCodeID;
- (AdaptPacketContext*)Clone;
- (NSArray*)TransactionsList;
- (AdaptValue*)NilObject;
- (void)Destroy;
- (void)dealloc;
- (AdaptPacketContextImpl*)getImpl;
@end

@interface AdaptEnvironment : NSObject

+ (BOOL)Initialize:(BOOL)test_mode;
+ (AdaptPacketContext*)EmptyPacket:(BOOL)secure;
+ (AdaptPacketContext*)CreatePacket:(AdaptEvaluationUnit*)unit seed:(NSString*)seed entropy:(NSString*)entropy secure:(BOOL)secure;
+ (AdaptValue*)SystemTime;
+ (AdaptValue*)ParseTime:(NSString*)timestamp;
+ (AdaptValue*)GetRandomBytes:(NSInteger)length;
+ (void)setError:(NSString*)error;
+ (BOOL)hasError;
+ (NSString*)getError;
+ (void)clearError;
//+ (NSInteger)countObjectsOutstanding;
@end
