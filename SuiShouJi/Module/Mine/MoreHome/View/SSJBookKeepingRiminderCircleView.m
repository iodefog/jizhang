//
//  SSJBookKeepingRiminderCircleView.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/3/3.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBookKeepingRiminderCircleView.h"
#import "SSJFundingTypeTableViewCell.h"
#import "SSJBookkeepingRiminderCell.h"

@interface SSJBookKeepingRiminderCircleView()
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) UIView *topView;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UIButton *closeButton;
@property (nonatomic,strong) UIButton *comfirmButton;
@end
@implementation SSJBookKeepingRiminderCircleView{
    NSArray *_weekdayArray;
    NSMutableArray *_selectWeekdayArray;
}

#pragma mark - Lifecycle
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryFillColor];
        _weekdayArray = [[NSMutableArray alloc]initWithArray:@[@"周日",@"周一",@"周二",@"周三",@"周四",@"周五",@"周六"]];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        [self addSubview:self.tableView];
        [self addSubview:self.topView];
        [self sizeToFit];
    }
    return self;
}

-(CGSize)sizeThatFits:(CGSize)size{
    return CGSizeMake([UIApplication sharedApplication].keyWindow.width, 370);
}

- (void)show {
    if (self.superview) {
        return;
    }
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    self.top = keyWindow.height;
    [keyWindow ssj_showViewWithBackView:self backColor:[UIColor blackColor] alpha:0.3 target:self touchAction:@selector(dismiss) animation:^{
        self.bottom = keyWindow.height;
    } timeInterval:0.25 fininshed:NULL];
}

- (void)dismiss {
    if (!self.superview) {
        return;
    }
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    [self.superview ssj_hideBackViewForView:self animation:^{
        self.top = keyWindow.bottom;
    } timeInterval:0.25 fininshed:NULL];
}


-(void)layoutSubviews{
    [super layoutSubviews];
    self.tableView.bottom = self.height;
    self.tableView.size = CGSizeMake(self.width, 320);
    self.topView.size = CGSizeMake(self.width, 50);
    self.topView.leftBottom = CGPointMake(0, self.tableView.top);
    self.titleLabel.center = CGPointMake(self.topView.width / 2, self.topView.height / 2);
    self.closeButton.centerY = self.topView.height / 2;
    self.closeButton.left = 10;
    self.comfirmButton.size = CGSizeMake(36, 21);
    self.comfirmButton.centerY = self.topView.height / 2;
    self.comfirmButton.right = self.width - 10;
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SSJFundingTypeTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (cell.selectedOrNot) {
        [_selectWeekdayArray removeObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row + 1]];
    }else{
        [_selectWeekdayArray addObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row + 1]];
    }
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _weekdayArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"SSJRiminderCircleCell";
    SSJFundingTypeTableViewCell *RiminderCircleCell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!RiminderCircleCell) {
        RiminderCircleCell = [[SSJFundingTypeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    if ([_selectWeekdayArray containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row + 1]]) {
        RiminderCircleCell.selectedOrNot = YES;
    }else{
        RiminderCircleCell.selectedOrNot = NO;
    }
    RiminderCircleCell.cellTitle = [_weekdayArray ssj_safeObjectAtIndex:indexPath.row];
    return RiminderCircleCell;
}


-(UIView *)topView{
    if (!_topView) {
        _topView = [[UIView alloc]init];
        _topView.backgroundColor = [UIColor clearColor];
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.text = @"重复";
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        _titleLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        [_topView ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
        [_topView ssj_setBorderStyle:SSJBorderStyleBottom];
        [_topView ssj_setBorderWidth:1];
        [_titleLabel sizeToFit];
        [_topView addSubview:_titleLabel];
        _closeButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 23, 23)];
        [_closeButton setImage:[[UIImage imageNamed:@"close"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        _closeButton.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor];
        [_closeButton addTarget:self action:@selector(closeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_topView addSubview:_closeButton];
        _comfirmButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 23, 23)];
        _comfirmButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_comfirmButton setTitle:@"确定" forState:UIControlStateNormal];
        [_comfirmButton setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor] forState:UIControlStateNormal];
        [_comfirmButton addTarget:self action:@selector(comfirmButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        _comfirmButton.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        [_topView addSubview:_comfirmButton];
    }
    return _topView;
}

-(UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.width, 320)];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

-(void)closeButtonClicked:(id)sender{
    [self dismiss];
}

-(void)comfirmButtonClicked:(id)sender{
    NSArray *tempArr =  [_selectWeekdayArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
        if ([obj1 intValue] > [obj2 intValue]){
            return NSOrderedDescending;
        }
        if ([obj1 intValue] < [obj2 intValue]){
            return NSOrderedAscending;
        }
        return NSOrderedSame;
    }];
    NSString *dateNumString = [tempArr componentsJoinedByString:@","];
    NSString *dateString;
    if (tempArr.count == 7) {
        dateString = @"每天";
    }else if (tempArr.count == 5 && ![tempArr containsObject:@"1"] &&  ![tempArr containsObject:@"7" ]){
        dateString = @"每个工作日";
    }else if (tempArr.count == 2 && [tempArr containsObject:@"1"] &&  [tempArr containsObject:@"7" ]){
        dateString = @"每个周末";
    }else{
        NSMutableArray *array = [[NSMutableArray alloc]init];
        for (int i = 0; i < tempArr.count; i ++) {
            NSInteger date = [[tempArr objectAtIndex:i] intValue];
            switch (date) {
                case 1:
                    [array addObject:@"周日"];
                    break;
                case 2:
                    [array addObject:@"周一"];
                    break;
                case 3:
                    [array addObject:@"周二"];
                    break;
                case 4:
                    [array addObject:@"周三"];
                    break;
                case 5:
                    [array addObject:@"周四"];
                    break;
                case 6:
                    [array addObject:@"周五"];
                    break;
                case 7:
                    [array addObject:@"周六"];
                    break;
                default:
                    break;
            }
        }
        dateString = [array componentsJoinedByString:@","];
    }
    if (self.circleSelectBlock) {
        self.circleSelectBlock(dateNumString,dateString);
    }
    [self dismiss];
}

-(void)setSelectWeekStr:(NSString *)selectWeekStr{
    _selectWeekStr = selectWeekStr;
    _selectWeekdayArray = [[NSMutableArray alloc]initWithArray:[self.selectWeekStr componentsSeparatedByString:@","]];
    [self.tableView reloadData];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
