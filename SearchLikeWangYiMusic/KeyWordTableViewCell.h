//
//  KeyWordTableViewCell.h
//  DataAnalysisPlatform
//
//  Created by whn on 2016/12/15.
//  Copyright © 2016年 whn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KeyWordTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *KSearchBtn;
@property (weak, nonatomic) IBOutlet UILabel *KText;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *kWidth;

@end
