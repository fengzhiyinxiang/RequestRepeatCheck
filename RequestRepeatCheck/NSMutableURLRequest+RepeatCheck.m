//
//  NSMutableURLRequest+RepeatCheck.m
//  EbikeMaintain
//
//  Created by QF on 2018/5/17.
//  Copyright © 2018年 jingyao. All rights reserved.
//

#import "NSMutableURLRequest+RepeatCheck.h"
#import <objc/runtime.h>

//保存上次请求相关参数的Model
@interface QFRequestRepeatCheckModel : NSObject

@property (nonatomic,assign) double repeatPeriod;
@property (nonatomic,copy) NSURL *lastlURL;
@property (nonatomic,copy) NSData *lastHTTPBody;
@property (nonatomic,assign) double lastTimeInterval;

+ (QFRequestRepeatCheckModel*)sharedRequestRepeatCheckModel;

@end

@implementation QFRequestRepeatCheckModel

+ (QFRequestRepeatCheckModel*)sharedRequestRepeatCheckModel
{
    static QFRequestRepeatCheckModel* sharedRequestRepeatCheckModel = nil;
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        sharedRequestRepeatCheckModel = [[QFRequestRepeatCheckModel alloc] init];
        sharedRequestRepeatCheckModel.repeatPeriod = 2;
    });
    return sharedRequestRepeatCheckModel;
}

@end

@implementation NSMutableURLRequest (RepeatCheck)

+ (void)load{
#ifdef DEBUG
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        method_exchangeImplementations(class_getInstanceMethod([self class], @selector(setHTTPBody:)),
                                       class_getInstanceMethod([self class], @selector(my_setHTTPBody:)));
    });
#endif
}

+(void)setRepeatPeriod:(double)repeatPeriod{
    if (repeatPeriod) {
        [QFRequestRepeatCheckModel sharedRequestRepeatCheckModel].repeatPeriod = repeatPeriod;
    }
}

- (void)my_setHTTPBody:(NSData *)HTTPBody{
    [self my_setHTTPBody:HTTPBody];
    [self repeatCheckWithHTTPBody:HTTPBody];
}

- (void)repeatCheckWithHTTPBody:(NSData *)HTTPBody{
    QFRequestRepeatCheckModel *requestRepeatCheckModel = [QFRequestRepeatCheckModel sharedRequestRepeatCheckModel];
    double nowTimeInterval = [[NSDate date] timeIntervalSince1970];
    NSURL *lastlURL = requestRepeatCheckModel.lastlURL;
    BOOL isGET = [self.HTTPMethod isEqualToString:@"GET"];
    
//   如果URL地址相同 则进行判断
    if ([self.URL.absoluteString isEqualToString:lastlURL.absoluteString]) {
        NSData *lastHTTPBody = requestRepeatCheckModel.lastHTTPBody;
        double lastTimeInterval = requestRepeatCheckModel.lastTimeInterval;
        double repeatPeriod = requestRepeatCheckModel.repeatPeriod;
        BOOL repeatPeriodBool = (nowTimeInterval - lastTimeInterval < repeatPeriod);
        
        if (isGET){
//            如果是GET方法 则判断时间间隔和请求体是否同为nil
            if (repeatPeriodBool && HTTPBody == lastHTTPBody) {
                NSLog(@"\n\n\n%.1lf秒内多次请求 SameHTTPRequest \n%@\n\n\n",repeatPeriod,self.URL);
            }
        }else {
//            如果不是GET方法则判断时间间隔和请求体是否相同
            if (repeatPeriodBool && [HTTPBody isEqualToData:lastHTTPBody]){
                NSLog(@"\n\n\n%.1lf秒内多次请求 SameHTTPRequest \n%@\n%@\n\n\n",repeatPeriod,self.URL,[self formatHTTPBody:HTTPBody]);
            }
        }
    }
    
//    更新请求相关参数
    requestRepeatCheckModel.lastlURL = [self.URL copy];
    requestRepeatCheckModel.lastTimeInterval = nowTimeInterval;
    
//     如果是 GET 请求或者 HTTPBody 有值 则赋值 这个写法不好理解 但是我是不会告诉你原因的
    if (HTTPBody || isGET){
        requestRepeatCheckModel.lastHTTPBody = [HTTPBody copy];
    }
}

//默认使用json格式转换 否则直接转换为字符串
-(id)formatHTTPBody:(NSData*)HTTPBody{
    id formatHTTPBody = [NSJSONSerialization JSONObjectWithData:HTTPBody options:NSJSONReadingMutableLeaves error:nil];
    if (formatHTTPBody) {
        return formatHTTPBody;
    }else{
        formatHTTPBody = [[NSString alloc] initWithData:HTTPBody encoding:NSUTF8StringEncoding];
        return formatHTTPBody? :@"";
    }
}

@end
