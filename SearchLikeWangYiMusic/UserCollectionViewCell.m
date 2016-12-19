//
//  UserCollectionViewCell.m
//  DataAnalysisPlatform
//
//  Created by whn on 2016/11/21.
//  Copyright © 2016年 whn. All rights reserved.
//

#import "UserCollectionViewCell.h"


@implementation UserCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        self.backgroundColor = [UIColor whiteColor];
        NSArray *arrCell = [[NSBundle mainBundle] loadNibNamed:@"UserCollectionViewCell" owner:self options:nil];
        if (arrCell.count < 1) {
            return nil;
        }
        if (![[arrCell objectAtIndex:0] isKindOfClass:[UICollectionViewCell class]]) {
            return nil;
        }
        self = [arrCell objectAtIndex:0];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    
    
}

@end
