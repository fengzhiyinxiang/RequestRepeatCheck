//
//  NSMutableURLRequest+RepeatCheck.h
//  EbikeMaintain
//
//  Created by QF on 2018/5/17.
//  Copyright © 2018年 jingyao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableURLRequest (RepeatCheck)

//如果两次请求有相同HTTPBody且两次请求时间间隔小于这个值 则判定为重复请求 默认值为2秒
+(void)setRepeatPeriod:(double)repeatPeriod;

@end
