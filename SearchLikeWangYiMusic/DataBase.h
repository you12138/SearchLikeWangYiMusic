//
//  DataBase.h
//  DataAnalysisPlatform
//
//  Created by whn on 2016/12/16.
//  Copyright © 2016年 whn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SearchModel.h"

@interface DataBase : NSObject

/**
 * 创建单例接口
 */
+ (DataBase *)shareDataBase;

#pragma mark -

/**
 * 收藏接口
 */
- (void)saveModel:(SearchModel *)model;
/**
 * 判断是否已经收藏
 */
- (BOOL)isHadSaveModel:(SearchModel *)model;
/**
 * 获取收藏的所有数据
 */
- (NSArray *)selectAllModel;
/**
 * 删除一个收藏
 */
- (void)deleteOneModelByStr:(NSString *)str;

@end
