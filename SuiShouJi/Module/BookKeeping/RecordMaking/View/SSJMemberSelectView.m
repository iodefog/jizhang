//
//  SSJMemberSelectView.m
//  SuiShouJi
//
//  Created by ricky on 16/7/18.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJMemberSelectView.h"
#import "SSJBaseTableViewCell.h"
#import "SSJChargeMemberItem.h"
#import "SSJDatabaseQueue.h"
#import "SSJNewMemberViewController.h"
#import "SSJMemberTableViewCell.h"

static NSString *const kMemberTableViewCellIdentifier = @"kMemberTableViewCellIdentifier";

@interface SSJMemberSelectView()

@property(nonatomic, strong) UITableView *tableView;

@property(nonatomic, strong) NSArray *items;

@property(nonatomic, strong) UIImageView *accessoryView;

@property(nonatomic, strong) UIView *topView;

@end

@implementation SSJMemberSelectView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryFillColor];
        [self addSubview:self.topView];
        [self addSubview:self.tableView];
        [self.tableView registerClass:[SSJMemberTableViewCell class] forCellReuseIdentifier:kMemberTableViewCellIdentifier];
        [self sizeToFit];
    }
    return self;
}

-(CGSize)sizeThatFits:(CGSize)size{
    return CGSizeMake(SSJSCREENWITH, 295);
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.topView.leftTop = CGPointMake(0, 0);
    self.tableView.size = CGSizeMake(self.width, self.height - 85);
    self.tableView.leftTop = CGPointMake(0, self.topView.bottom);
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SSJChargeMemberItem *item = [self.items ssj_safeObjectAtIndex:indexPath.row];
    if (indexPath.row != [tableView numberOfRowsInSection:0] - 1) {
        if ([self.selectedMemberItems containsObject:item]) {
            if (self.selectedMemberItems.count > 1) {
                [self.selectedMemberItems removeObject:item];
            }
        }else{
            [self.selectedMemberItems addObject:item];
        }
        [self.tableView reloadData];
        
        if (self.selectedMemberDidChangeBlock) {
            self.selectedMemberDidChangeBlock(self.selectedMemberItems);
        }
    }else{
        [SSJAnaliyticsManager event:@"dialog_add_member"];
        [self dismiss];
        if (self.addNewMemberBlock) {
            self.addNewMemberBlock();
        }
    }
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJMemberTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMemberTableViewCellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[SSJMemberTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kMemberTableViewCellIdentifier];
    }
    cell.selectable = YES;
    SSJChargeMemberItem *item = [self.items ssj_safeObjectAtIndex:indexPath.row];
    cell.memberItem = item;
    UIImageView *checkMarkImage = [[UIImageView alloc]initWithImage:[[UIImage imageNamed:@"checkmark"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    checkMarkImage.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
    cell.accessoryView = [self.selectedMemberItems containsObject:item] ? checkMarkImage : nil;
    return cell;
}

#pragma mark - getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.rowHeight = 44;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
        _tableView.separatorInset = UIEdgeInsetsZero;
        [_tableView ssj_clearExtendSeparator];

        [_tableView ssj_setBorderWidth:2];
        [_tableView ssj_setBorderStyle:SSJBorderStyleTop];
        [_tableView ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellIndicatorColor]];
    }
    return _tableView;
}

-(UIView *)topView{
    if (!_topView) {
        _topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.width, 85)];
        _topView.backgroundColor = [UIColor clearColor];
        UILabel *titleLab = [[UILabel alloc]init];
        titleLab.numberOfLines = 0;
        titleLab.textAlignment = NSTextAlignmentCenter;
        NSString *title = @"选择成员\n(可多选 , 多选即均分费用)";
        NSMutableAttributedString *atrributedTitle = [[NSMutableAttributedString alloc]initWithString:title];
        [atrributedTitle addAttribute:NSForegroundColorAttributeName value:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor] range:[title rangeOfString:@"选择成员"]];
        [atrributedTitle addAttribute:NSForegroundColorAttributeName value:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor] range:[title rangeOfString:@"(可多选 , 多选即均分费用)"]];
        [atrributedTitle addAttribute:NSFontAttributeName value:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2] range:[title rangeOfString:@"选择成员"]];
        [atrributedTitle addAttribute:NSFontAttributeName value:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3] range:[title rangeOfString:@"(可多选 , 多选即均分费用)"]];
        titleLab.attributedText = atrributedTitle;
        [titleLab sizeToFit];
        [_topView addSubview:titleLab];
        titleLab.centerX = _topView.width / 2;
        titleLab.top = 25;
        UIButton *comfirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [comfirmButton setTitle:@"确定" forState:UIControlStateNormal];
        [comfirmButton setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor] forState:UIControlStateNormal];
        [comfirmButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        comfirmButton.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        [_topView addSubview:comfirmButton];
        comfirmButton.size = CGSizeMake(50, 20);
        comfirmButton.centerY = _topView.height / 2;
        comfirmButton.right = _topView.width - 10;
        UIButton *manageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [manageButton setImage:[[UIImage imageNamed:@"chengyuan_guanli"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        manageButton.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
        [manageButton addTarget:self action:@selector(manageButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        manageButton.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        [_topView addSubview:manageButton];
        manageButton.size = CGSizeMake(40, 40);
        manageButton.centerY = _topView.height / 2;
        manageButton.left = 10;
    }
    return _topView;
}

#pragma mark - Event
- (void)manageButtonClick:(id)sender{
    [self dismiss];
    if (self.manageBlock) {
        self.manageBlock([self.items mutableCopy]);
    }
}

#pragma mark - Private
- (void)show {
    if (self.superview) {
        return;
    }
    [self getDataFromDb];
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    self.top = keyWindow.height;
    [keyWindow ssj_showViewWithBackView:self backColor:[UIColor blackColor] alpha:0.3 target:self touchAction:@selector(dismiss) animation:^{
        self.bottom = keyWindow.height;
        if (_showBlock) {
            _showBlock();
        }
    } timeInterval:0.25 fininshed:NULL];
}

- (void)dismiss {
    if (!self.superview) {
        return;
    }
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    [self.superview ssj_hideBackViewForView:self animation:^{
        self.top = keyWindow.bottom;
    } timeInterval:0.25 fininshed:^(BOOL complation) {
        if (_dismissBlock) {
            _dismissBlock();
        }
    }];
}

-(void)getDataFromDb{
    __weak typeof(self) weakSelf = self;
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSString *userid = SSJUSERID();
        FMResultSet *allMembersResult = [db executeQuery:@"select * from bk_member where cuserid = ? and istate <> 0 order by iorder asc , cadddate asc",userid];
        NSMutableArray *allMembersArr = [NSMutableArray array];
        NSMutableArray *idsArr = [NSMutableArray array];
        int count = 1;
        while ([allMembersResult next]) {
            SSJChargeMemberItem *item = [[SSJChargeMemberItem alloc]init];
            item.memberId = [allMembersResult stringForColumn:@"CMEMBERID"];
            [idsArr addObject:[NSString stringWithFormat:@"'%@'",item.memberId]];
            item.memberName = [allMembersResult stringForColumn:@"CNAME"];
            item.memberColor = [allMembersResult stringForColumn:@"CCOLOR"];
            item.memberOrder = [allMembersResult intForColumn:@"IORDER"];
            if (!item.memberOrder) {
                item.memberOrder = count;
            }
            count ++;
            [allMembersArr addObject:item];
        }
        [allMembersResult close];
        if (self.chargeId.length) {
            NSString *sql = [NSString stringWithFormat:@"select a.* , b.* from bk_member_charge as a , bk_member as b where a.cmemberid not in (%@) and a.ichargeid = '%@' and a.cmemberid = b.cmemberid and b.cuserid = '%@'",[idsArr componentsJoinedByString:@","],weakSelf.chargeId,userid];
            FMResultSet *result = [db executeQuery:sql];
            while ([result next]) {
                SSJChargeMemberItem *item = [[SSJChargeMemberItem alloc]init];
                item.memberId = [result stringForColumn:@"CMEMBERID"];
                item.memberName = [result stringForColumn:@"CNAME"];
                item.memberColor = [result stringForColumn:@"CCOLOR"];
                [allMembersArr addObject:item];
            }
        }
        SSJChargeMemberItem *item = [[SSJChargeMemberItem alloc]init];
        item.memberName = @"添加新成员";
        [allMembersArr addObject:item];
        weakSelf.items = [NSArray arrayWithArray:allMembersArr];
        [weakSelf updateSelectedMemberItems];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.tableView reloadData];
        });
    }];
}

-(void)setSelectedMemberItems:(NSMutableArray *)selectedMemberItems{
    _selectedMemberItems = selectedMemberItems;
    [self updateSelectedMemberItems];
    [self.tableView reloadData];
}

- (void)updateSelectedMemberItems {
    NSMutableArray *tmpMemberItems = [_selectedMemberItems copy];
    for (SSJChargeMemberItem *memberItem in tmpMemberItems) {
        if (self.items && ![self.items containsObject:memberItem]) {
            [_selectedMemberItems removeObject:memberItem];
        }
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
