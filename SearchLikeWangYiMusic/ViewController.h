//
//  ViewController.h
//  SearchLikeWangYiMusic
//
//  Created by whn on 2016/12/19.
//  Copyright © 2016年 kk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

/**
 最近做的项目中需要到一个仿照网易云音乐的搜索功能，我把它抽离出来供大家分享，有一些写的不好的地方，欢迎大家指正
 我在这里用朋友的测试接口展示数据，仅供测试使用，请勿进行商业用途
 **/
/**
 这里会讲一下基本的搜索功能的搭建，首先是当点击搜索框的时候，调起键盘并显示搜索历史记录，然后在点击记录时返回搜索数据
 当点击键盘时候，显示匹配到的关键字，点击字段返回数据并将该字段存入到历史记录中
 虽然搜索功能很小很简单，但是不细心的话也会出现很多bug，我会把我想到的一些注意事项写在项目中，欢迎大家指正补充
 **/

@end

