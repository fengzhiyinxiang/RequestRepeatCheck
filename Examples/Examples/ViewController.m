//
//  ViewController.m
//  Examples
//
//  Created by QF on 2018/11/21.
//  Copyright © 2018年 QF. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad{
    [super viewDidLoad];
}

- (IBAction)getRequest{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.baidu.com/?userName=fengzhiyinxiang&password=123456"]];
    NSURLRequest *request =[NSURLRequest requestWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *sessionDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
       
    }];
    [sessionDataTask resume];
}

- (IBAction)postRequest{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.baidu.com/"]];
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    NSString *args = [NSString stringWithFormat:@"userName=fengzhiyinxiang&password=123456"];
    request.HTTPBody = [args dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *sessionDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
      
    }];
    [sessionDataTask resume];
}


@end
