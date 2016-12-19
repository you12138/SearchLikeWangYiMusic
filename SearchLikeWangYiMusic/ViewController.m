//
//  ViewController.m
//  SearchLikeWangYiMusic
//
//  Created by whn on 2016/12/19.
//  Copyright © 2016年 kk. All rights reserved.
//

/**先搭建一个搜索完成后展示搜索数据的界面，这里用一个collectionView来展示数据**/
#import "ViewController.h"
#import "URL.h"
#import "NetWorkSingleton.h"
#import "UIImageView+WebCache.h"
#import "DataBase.h"
#import "CollectionModel.h"

#import "HistoryTableViewCell.h"
#import "KeyWordTableViewCell.h"
#import "UserCollectionViewCell.h"

#define cellID @"CollectionCell"
#define tableCellId @"tcellID"

#define History @"history"
#define keyWord @"keyWord"

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

#define cellW 130
#define cellH 150



@interface ViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UICollectionView *myCollection;  //

@property (nonatomic, strong) UITableView *myTable;            //

@property (nonatomic, strong) UITextField *searchTextField;    // 搜索框

@property (nonatomic, strong) NSMutableArray *dataSource;              // cell数据源
@property (nonatomic, strong) NSMutableArray *textFieldDataSource;     // 匹配字段数据源
@property (nonatomic, strong) NSMutableArray *historyDataSource;       // 搜索历史数据源
/**我在这里用一个替换字段接收请求下来的匹配字段的数据。。不这样做的话，在匹配字段返回的cell时，如果是在汉语模式下编辑，在没有确定输入字段时，此时已经匹配到了字段，但是如果点击的时候，在点击事件中，原来的数据源是空的，可能是我在哪里清空了原来的数据源，我没有找到，只能用一个新的数据源来替代。英文模式下输入，暂时没有发现这种问题（读这个源码的朋友如果能改进这个错误请私信我，万分感谢！！！）**/
@property (nonatomic, strong) NSMutableArray *placeTextDataSource;     // 替换匹配字段

@property (nonatomic, strong) NSString *judgeStr;   // 用来判断展示的table

@property (nonatomic, strong) SearchModel *model;

// 输入显示字段
@property (nonatomic, strong) NSString *textFieldStr;

@end

@implementation ViewController

/**
 * 懒加载数据源
 */
- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        self.dataSource = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataSource;
}

- (NSMutableArray *)textFieldDataSource
{
    if (!_textFieldDataSource) {
        self.textFieldDataSource = [NSMutableArray arrayWithCapacity:0];
    }
    return _textFieldDataSource;
}

- (NSMutableArray *)historyDataSource
{
    if (!_historyDataSource) {
        self.historyDataSource = [NSMutableArray arrayWithCapacity:0];
    }
    return _historyDataSource;
}

- (NSMutableArray *)placeTextDataSource
{
    if (!_placeTextDataSource) {
        self.placeTextDataSource = [NSMutableArray arrayWithCapacity:0];
    }
    return _placeTextDataSource;
}


#warning viewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor blueColor];
    
    // 初始化searchModel
    self.model = [[SearchModel alloc] init];
    
    [self creatCollectionView];
}

/**
 * 创建一个collectionView
 */
- (void)creatCollectionView
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    self.myCollection = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 60, ScreenWidth, ScreenHeight - 60) collectionViewLayout:flowLayout];
    self.myCollection.backgroundColor = [UIColor orangeColor];
    _myCollection.dataSource = self;
    _myCollection.delegate = self;
    [self.view addSubview:_myCollection];
    [_myCollection registerClass:[UserCollectionViewCell class] forCellWithReuseIdentifier:cellID];
    [self.view addSubview:_myCollection];
    
    // 在collection上添加一个搜索框
    self.searchTextField = [[UITextField alloc] initWithFrame:CGRectMake(50, 20, ScreenWidth-100, 40)];
    _searchTextField.placeholder = @"🔍输入关键字查询";
    _searchTextField.textColor = [UIColor redColor];
    _searchTextField.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:_searchTextField];
    // 设置textfield的return键为搜索键
    _searchTextField.returnKeyType = UIReturnKeySearch;
    // 设置textfield的代理
    _searchTextField.delegate = self;
    
}

/**
 * table的cell有两种，一种是历史的cell，一种是匹配关键字的cell，这里我建了两个cell
 * 分别展示，根据传入的一个标识分别创建（因为两个cell只有一个button的区别，也可以创建一 
 * 个cell再来控制button的显隐性。不过我特么就是想创建两个）
 */
- (void)creatTableViewWithStr:(NSString *)str
{
    self.myTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 60, ScreenWidth, ScreenHeight-60) style:(UITableViewStylePlain)];
    if ([str isEqualToString:@"history"]) {
        [_myTable registerNib:[UINib nibWithNibName:@"HistoryTableViewCell" bundle:nil] forCellReuseIdentifier:tableCellId];
    }else {
        [_myTable registerNib:[UINib nibWithNibName:@"KeyWordTableViewCell" bundle:nil] forCellReuseIdentifier:tableCellId];
    }    _myTable.delegate = self;
    _myTable.dataSource = self;
    
    // 当tableView滑动时收起键盘
    _myTable.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    // 取消tableView的分割线
    _myTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.view addSubview:_myTable];
}

#pragma mark ------- 数据请求 --------
/**
 * 请求collectionView数据
 */
- (void)getDataByText:(NSString *)text
{
    
    [self.dataSource removeAllObjects];
    
    NSString *url = [NSString stringWithFormat:SearchUrl, text];
    
    [[NetWorkSingleton shareManager] getResultWithParameter:nil url:url showHUD:YES successBlock:^(id responseBody) {
        
        //        NSLog(@"%@", responseBody);
        
        NSArray *arr = responseBody[@"data"];
        
        
        for (NSDictionary *dic in arr) {
            CollectionModel *model = [[CollectionModel alloc] init];
            [model setValuesForKeysWithDictionary:dic];
            [self.dataSource addObject:model];
        }
        
        [_myCollection reloadData];
        
    } failureBlock:^(NSError *error) {
        
    }];
    
}

/**
 * 请求匹配关键字
 */
- (void)getDataByTextfieldText:(NSString *)textFieldText
{
    
    
    NSString *str = [NSString stringWithFormat:KeyWordUrl, textFieldText];
    //    NSLog(@"%@", str);
    [[NetWorkSingleton shareManager] getResultWithParameter:nil url:str showHUD:NO successBlock:^(id responseBody) {
        
        NSArray *arr = responseBody[@"data"];
        for (NSDictionary *dic in arr) {
            NSString *str = dic[@"title"];
            [self.textFieldDataSource addObject:str];
        }
        
        [_myTable reloadData];
        
    } failureBlock:^(NSError *error) {
        
    }];
}


#pragma mark ---  TextFieldDelegate
/**
 * 点击键盘搜索按钮
 */
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // 收起键盘
    [_searchTextField resignFirstResponder];
    // 移除tableView
    [_myTable removeFromSuperview];
    // 先清空数据源，然后请求数据
    [self.dataSource removeAllObjects];
    [self getDataByText:textField.text];
    
    // 存入搜索历史
    _model.historyStr = textField.text;
    if (textField.text.length>0) {
        if (![[DataBase shareDataBase] isHadSaveModel:_model]) {
            [[DataBase shareDataBase] saveModel:_model];
        }
    }
    
    
    return YES;
}
/**
 * 点击输入框开始编辑时走这个方法。 （我们需要点击输入框时，在输入框下面出现一
 * 个tableView来展示搜索的历史记录）
 */
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
    // 先移除之前添加上的tableView
    [self.myTable removeFromSuperview];
    // 再次添加
    self.judgeStr = History;
    [self creatTableViewWithStr:self.judgeStr];
    
    // 打开输入框后，展示搜索历史记录
    self.historyDataSource = [NSMutableArray arrayWithArray:[[DataBase shareDataBase] selectAllModel]];
    [self.myTable reloadData];
}

/**
 * 当我们开始编辑时，根据我们当前输入的字段进行匹配关键字，需要用到这个方法。 这个方法
 * 是当输入框内容开始发生变化时调用
 */
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    // 输入时开始匹配关键字，显示另一个tableView
    // 先移除之前添加上的tableView
    [self.myTable removeFromSuperview];
    // 再次添加
    self.judgeStr = keyWord;
    [self creatTableViewWithStr:self.judgeStr];
    
    self.textFieldStr = string;
    
    // 请求匹配关键字
    // 先清空保存的数据
    [self.textFieldDataSource removeAllObjects];
    [self getDataByTextfieldText:self.textFieldStr];
    
    return YES;
}


#pragma mark ---- UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSource.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UserCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionCell" forIndexPath:indexPath];
    CollectionModel *model = self.dataSource[indexPath.item];
    [cell.qr_codeImg sd_setImageWithURL:[NSURL URLWithString:model.qr_code]];
    cell.userName.text = model.title;
    cell.backgroundColor = [UIColor whiteColor];
    
    return cell;
}


#pragma mark ---- UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return (CGSize){cellW, cellH};
}


- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5, 5, 5, 5);
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 5.f;
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 5.f;
}


#pragma mark ---- UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

// 点击高亮
- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor greenColor];
    
}


// 选中某item
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}


// 长按某item，弹出copy和paste的菜单
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

// 使copy和paste有效
- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(nullable id)sender
{
    if ([NSStringFromSelector(action) isEqualToString:@"copy:"] || [NSStringFromSelector(action) isEqualToString:@"paste:"])
    {
        return YES;
    }
    
    return NO;
}

//
- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(nullable id)sender
{
    if([NSStringFromSelector(action) isEqualToString:@"copy:"])
    {
                NSLog(@"-------------执行拷贝-------------");
    }
    else if([NSStringFromSelector(action) isEqualToString:@"paste:"])
    {
        NSLog(@"-------------执行粘贴-------------");
    }
}



#pragma mark   -----  tableView Delegate   ------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.judgeStr isEqualToString:History]) {
        return self.historyDataSource.count;
    }else {
        // 用一个替换数组接收数据
        self.placeTextDataSource = [NSMutableArray arrayWithArray:self.textFieldDataSource];
        return self.textFieldDataSource.count + 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.judgeStr isEqualToString:History]) {
        HistoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableCellId forIndexPath:indexPath];
        _model = self.historyDataSource[indexPath.row];
        cell.HText.text = _model.historyStr;
        [cell.deleteBtn addTarget:self action:@selector(deleteHistoryWithIndexpath:) forControlEvents:(UIControlEventTouchUpInside)];
        return cell;
    }else {
        KeyWordTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableCellId forIndexPath:indexPath];
        if (indexPath.row == 0) {
            
            cell.KSearchBtn.hidden = YES;
            cell.KText.text = [NSString stringWithFormat:@"搜索“%@”", self.textFieldStr];
            
            cell.KText.textColor = [UIColor blueColor];
            cell.KText.textAlignment = NSTextAlignmentLeft;
            cell.KText.font = [UIFont systemFontOfSize:15.0];
        } else {
            cell.KSearchBtn.hidden = NO;
            cell.KText.textColor = [UIColor blackColor];
            cell.KText.text = self.textFieldDataSource[indexPath.row-1];
        }
        return cell;
    }

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_searchTextField resignFirstResponder];
    
    if ([self.judgeStr isEqualToString:@"history"]) {
        
        [self.myTable removeFromSuperview];
        _model = self.historyDataSource[indexPath.row];
        
        _searchTextField.text = _model.historyStr;
        [self getDataByText:_model.historyStr];
        
    }else{
        
        if (indexPath.row == 0) {
            _searchTextField.text = self.textFieldStr;
            [self getDataByText:self.textFieldStr];
        } else {
            
            if (self.placeTextDataSource.count > 0) {
                NSLog(@".....%@", self.placeTextDataSource[indexPath.row - 1]);
                _searchTextField.text = self.placeTextDataSource[indexPath.row - 1];
                [self getDataByText:self.placeTextDataSource[indexPath.row - 1]];
                
            }
            
        }
        [self.myTable removeFromSuperview];
        _model.historyStr = _searchTextField.text;
        if (![[DataBase shareDataBase] isHadSaveModel:_model]) {
            [[DataBase shareDataBase] saveModel:_model];
        }
        
    }

}
/**
 * 删除历史记录
 */
- (void)deleteHistoryWithIndexpath:(UIButton *)sender
{
    NSIndexPath *indexP = [self.myTable indexPathForSelectedRow];
    _model = self.historyDataSource[indexP.row];
    [[DataBase shareDataBase] deleteOneModelByStr:_model.historyStr];
    [self.historyDataSource removeObject:_model];
    [self.myTable reloadData];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
