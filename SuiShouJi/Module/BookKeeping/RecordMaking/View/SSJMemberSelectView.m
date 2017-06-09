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
#import "SSJDatabaseSequence.h"

#pragma mark - SSJMemberSelectViewHelper
#pragma mark -
@interface SSJMemberSelectViewHelper : NSObject

@end

@implementation SSJMemberSelectViewHelper

+ (id)queryMemberItemsInDatabase:(SSJDatabase *)db {
    FMResultSet *rs = [db executeQuery:@"select * from bk_member where cuserid = ? and istate <> 0 order by iorder asc , cadddate asc", SSJUSERID()];
    if (!rs) {
        return [db lastError];
    }
    NSMutableArray *memberItems = [NSMutableArray array];
    int count = 1;
    while ([rs next]) {
        SSJChargeMemberItem *item = [[SSJChargeMemberItem alloc] init];
        item.memberId = [rs stringForColumn:@"CMEMBERID"];
        item.memberName = [rs stringForColumn:@"CNAME"];
        item.memberColor = [rs stringForColumn:@"CCOLOR"];
        item.memberOrder = [rs intForColumn:@"IORDER"];
        if (!item.memberOrder) {
            item.memberOrder = count;
        }
        count ++;
        [memberItems addObject:item];
    }
    [rs close];
    return memberItems;
}

+ (id)queryMemberItemsForChargeId:(NSString *)chargeId inDatabase:(SSJDatabase *)db {
    FMResultSet *rs = [db executeQuery:@"select a.* , b.* from bk_member_charge as a , bk_member as b where a.ichargeid = ? and a.cmemberid = b.cmemberid", chargeId];
    if (!rs) {
        return [db lastError];
    }
    
    NSMutableArray *memberItems = [NSMutableArray array];
    while ([rs next]) {
        SSJChargeMemberItem *item = [[SSJChargeMemberItem alloc]init];
        item.memberId = [rs stringForColumn:@"CMEMBERID"];
        item.memberName = [rs stringForColumn:@"CNAME"];
        item.memberColor = [rs stringForColumn:@"CCOLOR"];
        [memberItems addObject:item];
    }
    [rs close];
    
    return memberItems;
}

+ (id)queryMemberItemsForPeriodChargeConfigId:(NSString *)configId inDatabase:(SSJDatabase *)db {
    NSString *memberIdsStr = [db stringForQuery:@"select cmemberids from bk_charge_period_config where iconfigid = ?", configId];
    NSArray *memberIds = [memberIdsStr componentsSeparatedByString:@","];
    if (memberIds.count == 0) {
        return nil;
    }
    
    NSMutableArray *bindParams = [NSMutableArray arrayWithCapacity:memberIds.count];
    NSMutableDictionary *params = [@{@"userId":SSJUSERID()} mutableCopy];
    [memberIds enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *key = [NSString stringWithFormat:@"memberId_%d", (int)idx];
        [bindParams addObject:[NSString stringWithFormat:@":%@", key]];
        params[key] = obj;
    }];
    
    NSString *sql = [NSString stringWithFormat:@"select cmemberid, cname, ccolor from bk_member where cmemberid in (%@) and cuserid = :userId", [bindParams componentsJoinedByString:@", "]];
    FMResultSet *rs = [db executeQuery:sql withParameterDictionary:params];
    if (!rs) {
        return [db lastError];
    }
    
    NSMutableArray *memberItems = [NSMutableArray array];
    while ([rs next]) {
        SSJChargeMemberItem *memberItem = [[SSJChargeMemberItem alloc] init];
        memberItem.memberId = [rs stringForColumn:@"cmemberid"];
        memberItem.memberName = [rs stringForColumn:@"cname"];
        memberItem.memberColor = [rs stringForColumn:@"ccolor"];
        [memberItems addObject:memberItem];
    }
    [rs close];
    
    return memberItems;
}

+ (id)queryDefaultMemberItemInDatabase:(SSJDatabase *)db {
    NSString *memberId = [NSString stringWithFormat:@"%@-0",SSJUSERID()];
    FMResultSet *rs = [db executeQuery:@"select cname, ccolor from bk_member where cmemberid = ?", memberId];
    if (!rs) {
        return [db lastError];
    }
    
    NSMutableArray *memberItems = [NSMutableArray array];
    while ([rs next]) {
        SSJChargeMemberItem *item = [[SSJChargeMemberItem alloc] init];
        item.memberId = memberId;
        item.memberName = [rs stringForColumn:@"cname"];
        item.memberColor = [rs stringForColumn:@"ccolor"];
        [memberItems addObject:item];
    }
    [rs close];
    
    return memberItems;
}

@end

#pragma mark - SSJMemberSelectView
#pragma mark -
static NSString *const kMemberTableViewCellIdentifier = @"kMemberTableViewCellIdentifier";

@interface SSJMemberSelectView()

@property (nonatomic, strong) SSJDatabaseSequence *dbSequence;

@property(nonatomic, strong) NSMutableArray<SSJChargeMemberItem *> *items;

@property(nonatomic, strong) NSMutableArray<SSJChargeMemberItem *> *selectedMemberItems;

// 如果chargeId或者preiodConfigId有值，则根据这两个id查询出的依赖的成员，如果没有值，就是默认成员
@property(nonatomic, strong) NSMutableArray<SSJChargeMemberItem *> *dependentMemberItems;

@property(nonatomic, strong) UITableView *tableView;

@property(nonatomic, strong) UIImageView *accessoryView;

@property(nonatomic, strong) UIView *topView;

@end

@implementation SSJMemberSelectView

- (void)dealloc {
    [self.dbSequence cancelAllTasks];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.items = [NSMutableArray array];
        self.selectedMemberItems = [NSMutableArray array];
        self.dependentMemberItems = [NSMutableArray array];
        self.dbSequence = [SSJDatabaseSequence sequence];
        [self addSubview:self.topView];
        [self addSubview:self.tableView];
        self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryFillColor];
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

- (void)show {
    if (self.superview) {
        return;
    }
    
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

- (void)reloadData:(void(^)())completion {
    SSJDatabaseSequenceCompoundTask *compoundTask = [SSJDatabaseSequenceCompoundTask taskWithTasks:@[[self loadAllMembersTask], [self loadSelectedMemberTask]] success:^{
        // 补充没有的流水依赖成员，比如当前流水依赖的成员已被删除，也要展示出来
        for (SSJChargeMemberItem *item in self.dependentMemberItems) {
            if (![self.items containsObject:item]) {
                [self.items addObject:item];
            }
        }
        
        SSJChargeMemberItem *item = [[SSJChargeMemberItem alloc] init];
        item.memberName = @"添加新成员";
        [self.items addObject:item];
        
        // 移除已经被删除的非依赖选中的成员
        NSMutableArray *tmpSelectedItems = [self.selectedMemberItems mutableCopy];
        for (SSJChargeMemberItem *item in tmpSelectedItems) {
            if (![self.items containsObject:item]) {
                [self.selectedMemberItems removeObject:item];
            }
        }
        [self.tableView reloadData];
        if (completion) {
            completion();
        }
    } failure:^(NSError * _Nonnull error) {
        [SSJAlertViewAdapter showError:error];
    }];
    [self.dbSequence addCompoundTask:compoundTask];
}

- (void)addSelectedMemberItem:(SSJChargeMemberItem *)item {
    if ([item isKindOfClass:[SSJChargeMemberItem class]]) {
        [self.selectedMemberItems addObject:item];
    }
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
        [_tableView registerClass:[SSJMemberTableViewCell class] forCellReuseIdentifier:kMemberTableViewCellIdentifier];
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
        
        [_topView ssj_setBorderWidth:1];
        [_topView ssj_setBorderStyle:SSJBorderStyleBottom];
        [_topView ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellIndicatorColor]];
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
- (SSJDatabaseSequenceTask *)loadAllMembersTask {
    [self.items removeAllObjects];
    return [SSJDatabaseSequenceTask taskWithHandler:^id _Nonnull(SSJDatabase * _Nonnull db) {
        return [SSJMemberSelectViewHelper queryMemberItemsInDatabase:db];
    } success:^(NSArray<SSJChargeMemberItem *> *result) {
        [self.items addObjectsFromArray:result];
    } failure:NULL];
}

- (SSJDatabaseSequenceTask *)loadSelectedMemberTask {
    [self.dependentMemberItems removeAllObjects];
    return [SSJDatabaseSequenceTask taskWithHandler:^id _Nonnull(SSJDatabase * _Nonnull db) {
        if (self.chargeId.length) {
            return [SSJMemberSelectViewHelper queryMemberItemsForChargeId:self.chargeId inDatabase:db];
        } else if (self.preiodConfigId.length) {
            return [SSJMemberSelectViewHelper queryMemberItemsForPeriodChargeConfigId:self.preiodConfigId inDatabase:db];
        } else {
            return [SSJMemberSelectViewHelper queryDefaultMemberItemInDatabase:db];
        }
    } success:^(NSArray<SSJChargeMemberItem *> *result) {
        [self.dependentMemberItems addObjectsFromArray:result];
        if (self.selectedMemberItems.count == 0) {
            [self.selectedMemberItems addObjectsFromArray:result];
        }
    } failure:NULL];
}

@end
