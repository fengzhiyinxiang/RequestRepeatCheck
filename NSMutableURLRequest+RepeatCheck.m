//
//  NSMutableURLRequest+RepeatCheck.m
//  EbikeMaintain
//
//  Created by QF on 2018/5/17.
//  Copyright © 2018年 jingyao. All rights reserved.
//

#import "NSMutableURLRequest+RepeatCheck.h"
#import <objc/runtime.h>

#define QFJudgeTimeIntervalKey @"QFJudgeTimeIntervalKey"
#define QFJudgeMaxDataLengthKey @"QFJudgeMaxDataLengthKey"
#define QFHTTPBodyKey @"QFHTTPBodyKey"
#define QFTimeIntervalKey @"QFTimeIntervalKey"

@implementation NSMutableURLRequest (RepeatCheck)

+ (void)load{
#ifdef Release
#else
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        method_exchangeImplementations(class_getInstanceMethod([self class], @selector(setHTTPBody:)),
                                       class_getInstanceMethod([self class], @selector(my_setHTTPBody:)));
    });
#endif
}

- (void)my_setHTTPBody:(NSData *)HTTPBody{
    [self my_setHTTPBody:HTTPBody];
    [self repeatCheckWithHTTPBody:HTTPBody];
}

+(NSMutableDictionary*)sharedMutDic
{
    static NSMutableDictionary* sharedMutDic = nil;
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        sharedMutDic = [[NSMutableDictionary alloc] init];
        [sharedMutDic setObject:@(2.0) forKey:QFJudgeTimeIntervalKey];
        [sharedMutDic setObject:@(1000) forKey:QFJudgeMaxDataLengthKey];
    }) ;
    return sharedMutDic;
}

+(void)setJudgeTimeInterval:(double)judgeTimeInterval{
    if (judgeTimeInterval) {
        NSNumber *judgeTimeIntervalNumber = [NSNumber numberWithDouble:judgeTimeInterval];
        [[self sharedMutDic] setObject:judgeTimeIntervalNumber forKey:QFJudgeTimeIntervalKey];
    }
}

+(void)setJudgeMaxDataLength:(NSInteger)judgeMaxDataLength{
    if (judgeMaxDataLength) {
        NSNumber *judgeMaxDataLengthNumber = [NSNumber numberWithDouble:judgeMaxDataLength];
        [[self sharedMutDic] setObject:judgeMaxDataLengthNumber forKey:QFJudgeMaxDataLengthKey];
    }
}

- (void)repeatCheckWithHTTPBody:(NSData *)HTTPBody{
    if (!HTTPBody) {
        return;
    }
    
    NSMutableDictionary *sharedMutDic = [NSMutableURLRequest sharedMutDic];
    NSInteger maxDataLengthKey = [sharedMutDic[QFJudgeMaxDataLengthKey] integerValue];
    
    if ([HTTPBody length] > maxDataLengthKey) {
        return;
    }
    
    NSData *lastHTTPBody = sharedMutDic[QFHTTPBodyKey];
    NSNumber *lastTimeIntervalNumber = sharedMutDic[QFTimeIntervalKey];
    
    double judgeTimeInterval = [sharedMutDic[QFJudgeTimeIntervalKey] doubleValue];

    double timeInterval = [[NSDate date] timeIntervalSince1970];
    
    if ([HTTPBody isEqualToData:lastHTTPBody]) {
        if (timeInterval - lastTimeIntervalNumber.doubleValue < judgeTimeInterval) {
            NSDictionary *HTTPBodyDic = [NSJSONSerialization JSONObjectWithData:HTTPBody options:NSJSONReadingMutableLeaves error:nil];
            NSLog(@"\n\n\n%.1lf秒内多次请求 SameHTTPBody %@\n\n\n",judgeTimeInterval,HTTPBodyDic);
        }
    }
    
    [sharedMutDic setObject:HTTPBody forKey:QFHTTPBodyKey];
    [sharedMutDic setObject:@(timeInterval) forKey:QFTimeIntervalKey];
}

@end
