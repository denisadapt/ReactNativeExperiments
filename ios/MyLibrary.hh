#pragma once

#import <Foundation/Foundation.h>

@interface MyLibrary : NSObject

+ (NSString*)greet:(NSString*)name;
+ (NSInteger)add:(NSInteger)a with:(NSInteger)b;
+ (NSString*)readFileContent:(NSString*)filename;

@end
