//
//  NetWorkSingleton.m
//  DataAnalysisPlatform
//
//  Created by whn on 2016/11/14.
//  Copyright © 2016年 whn. All rights reserved.
//

#import "NetWorkSingleton.h"
#import "MBProgressHUD+LNFCategory.h"
#import "UIView+Toast.h"
//#import "Public.h"
#define WINDOW [UIApplication sharedApplication].windows.firstObject
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@implementation NetWorkSingleton

+ (NetWorkSingleton *)shareManager
{
    static NetWorkSingleton *sharedNetWorkSingleton = nil;
    static dispatch_once_t OnceToken;
    dispatch_once(&OnceToken, ^{
        sharedNetWorkSingleton = [[self alloc] init];
    });
    return sharedNetWorkSingleton;
}

- (AFHTTPRequestOperationManager *)baseHTTPRequst
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setTimeoutInterval:20];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain", @"text/html",@"application/javascript",@"application/json", nil];
    return manager;
}

- (void)getResultWithParameter:(NSDictionary *)parameter url:(NSString *)url showHUD:(BOOL)show successBlock:(SuccessBlock)successBlock failureBlock:(FailureBlock)failureBlock
{
    if (show) {
        [MBProgressHUD showLoadingHUDToView:WINDOW];
    }
    
    AFHTTPRequestOperationManager *manager = [self baseHTTPRequst];
    NSString *urlStr = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    [manager GET:urlStr parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"数据请求成功");
        [MBProgressHUD hideLoadingHUDToView:WINDOW];
//        successBlock(responseObject);
        if (successBlock) {
            successBlock(responseObject);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [MBProgressHUD hideLoadingHUDToView:WINDOW];
        [WINDOW makeToast:@"网络异常" duration:2.0f position:[NSValue valueWithCGPoint:CGPointMake(kScreenWidth/2, kScreenHeight/2)]];
        if (failureBlock) {
//                NSString *errorStr = [error.userInfo objectForKey:@"NSLocalizedDescription"];
                failureBlock(error);
        }

        
    }];
}

- (void)postResultWithParameter:(NSDictionary *)parameter url:(NSString *)url showHUD:(BOOL)show successsBlock:(SuccessBlock)successBlock failureBlock:(FailureBlock)failureBlock
{
    if (show) {
        [MBProgressHUD showLoadingHUDToView:WINDOW];
    }
    AFHTTPRequestOperationManager *manager = [self baseHTTPRequst];
    NSString *urlStr = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    [manager POST:urlStr parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [MBProgressHUD hideLoadingHUDToView:WINDOW];
        if (successBlock) {
            successBlock(responseObject);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
       
        [MBProgressHUD hideLoadingHUDToView:WINDOW];
        [WINDOW makeToast:@"网络异常" duration:2.0f position:[NSValue valueWithCGPoint:CGPointMake(kScreenWidth/2, kScreenHeight/2)]];
        if (failureBlock) {
            failureBlock(error);
        }
        
    }];
}


@end
