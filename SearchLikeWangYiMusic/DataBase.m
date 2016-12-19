//
//  DataBase.m
//  DataAnalysisPlatform
//
//  Created by whn on 2016/12/16.
//  Copyright © 2016年 whn. All rights reserved.
//

#import "DataBase.h"
#import "FMDB.h"

@interface DataBase ()

@property (nonatomic, strong) FMDatabase *db;

@end

@implementation DataBase
// 创建单例

+ (DataBase *)shareDataBase
{
    static DataBase *single = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        single = [[DataBase alloc] init];
        [single creatDataBase];
    });
    return single;
}

// 创建数据库
- (void)creatDataBase
{
    // 在Documents文件夹下创建db.sqlite
    NSString *dbPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"db.splite"];
    
    // 初始化
    self.db = [FMDatabase databaseWithPath:dbPath];
    // 打开数据库
    [self.db open];
    // 创建表格
    [self creatTable];
    
}

- (void)creatTable
{
    BOOL isSuccess = [self.db executeUpdate:@"create table if not exists MV(id integer primary key autoincrement, historyStr text)"];
    NSLog(@"%@", isSuccess ? @"表格创建成功":@"表格创建失败");
}

- (BOOL)isHadSaveModel:(SearchModel *)model
{
    FMResultSet *set = [self.db executeQuery:@"select * from MV where historyStr = ?", model.historyStr];
    while ([set next]) {
        NSString *historyStr = [set stringForColumn:@"historyStr"];
        if ([model.historyStr isEqualToString:historyStr]) {
            return YES;
        }
    }
    return NO;
}

- (void)saveModel:(SearchModel *)model
{
    BOOL isSuccess = [self.db executeUpdate:@"insert into MV(historyStr) values (?)", model.historyStr];
    
    NSLog(@"%@", isSuccess ? @"收藏成功":@"收藏失败");
}

- (NSArray *)selectAllModel
{
    FMResultSet *set = [self.db executeQuery:@"select *from MV"];
    NSMutableArray *arr = [NSMutableArray array];
    while ([set next]) {
        NSString *historyStr = [set stringForColumn:@"historyStr"];
        SearchModel *model = [[SearchModel alloc] init];
        model.historyStr = historyStr;
        [arr addObject:model];
    }
    return arr;
}

- (void)deleteOneModelByStr:(NSString *)str
{
    BOOL isSuccess = [self.db executeUpdate:@"delete from MV where historyStr = ?", str];
    
    NSLog(@"%@", isSuccess ? @"删除成功":@"删除失败");
}

@end
