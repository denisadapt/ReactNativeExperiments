#pragma once

#import <Foundation/Foundation.h>

@class AdaptValueImpl;

@interface AdaptValue : NSObject {
    AdaptValueImpl* impl;
}
- (instancetype)init;
- (NSString*)Visualize;
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

@class AdaptEvaluationUnitImpl;

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

@class AdaptPacketContextImpl;

@interface AdaptPacketContext : NSObject {
    AdaptPacketContextImpl* impl;
}
- (instancetype)init;
- (instancetype)initWithContext:(AdaptPacketContext*)context;
- (AdaptPacketContext*)LoadFromFile:(NSString*)filename;
- (AdaptPacketContext*)LoadFromContents:(NSData*)bin;

- (AdaptValue*)ParseValue:(AdaptValue*)source;
- (AdaptValue*)ParseValueFromJSON:(NSString*)json;
- (AdaptValue*)CreateDictionary;
- (AdaptValue*)NewBinaryFromHex:(NSString*)hex;
- (AdaptValue*)NewBinaryFromBuffer:(NSData*)data;
- (AdaptValue*)ExecuteTransaction:(AdaptValue*)transaction :(NSString*)entropy_hex :(AdaptValue*)timestamp;
//- (AdaptFunctionInvocation*)GetFunction:(NSString*)functionName;
- (AdaptValue*)GetHash;
- (NSData*)Serialize;
- (AdaptValue*)GetContainerID;
- (AdaptValue*)GetCodeID;
- (AdaptPacketContext*)Clone;
//- (IteratorString*)TransactionsList;
- (void)Destroy;
- (void)dealloc;
- (AdaptPacketContextImpl*)getImpl;
@end

@interface AdaptEnvironment : NSObject

+ (BOOL)Initialize:(BOOL)test_mode;
+ (AdaptPacketContext*)EmptyPacket:(BOOL)secure;
+ (AdaptPacketContext*)CreatePacket:(AdaptEvaluationUnit*)unit :(NSString*)seed :(NSString*)entropy :(BOOL)secure;
+ (AdaptValue*)SystemTime;
+ (AdaptValue*)ParseTime:(NSString*)timestamp;
+ (AdaptValue*)GetRandomBytes:(NSInteger)length;
+ (void)setError:(NSString*)error;
+ (BOOL)hasError;
+ (NSString*)getError;
+ (void)clearError;
//+ (NSInteger)countObjectsOutstanding;
@end
