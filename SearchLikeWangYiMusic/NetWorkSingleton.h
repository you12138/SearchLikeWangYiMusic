//
//  NetWorkSingleton.h
//  DataAnalysisPlatform
//
//  Created by whn on 2016/11/14.
//  Copyright © 2016年 whn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

// 请求超时
#define TIMEOUT 30

typedef void(^SuccessBlock)(id responseBody);
typedef void(^FailureBlock)(NSError *error);

@interface NetWorkSingleton : NSObject

+ (NetWorkSingleton *)shareManager;
- (AFHTTPRequestOperationManager *)baseHTTPRequst;

#pragma mark * GET
- (void)getResultWithParameter:(NSDictionary *)parameter url:(NSString *)url showHUD:(BOOL)show successBlock:(SuccessBlock)successBlock failureBlock:(FailureBlock)failureBlock;

#pragma mark * POST
- (void)postResultWithParameter:(NSDictionary *)parameter url:(NSString *)url showHUD:(BOOL)show successsBlock:(SuccessBlock)successBlock failureBlock:(FailureBlock)failureBlock;

@end
