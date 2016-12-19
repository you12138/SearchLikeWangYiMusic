//
//  UserCollectionViewCell.h
//  DataAnalysisPlatform
//
//  Created by whn on 2016/11/21.
//  Copyright © 2016年 whn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *qr_codeImg;
@property (weak, nonatomic) IBOutlet UILabel *userName;

@end
