//
//  SSJDataImportViewController.m
//  SuiShouJi
//
//  Created by old lang on 2017/9/17.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJDataImportViewController.h"

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - _SSJDataImportTopView
#pragma mark -
@interface _SSJDataImportTopView : UIView

@property (nonatomic, strong) UILabel *titleLab;

@property (nonatomic, strong) UIImageView *icon_1;

@property (nonatomic, strong) UILabel *nameLab_1;

@property (nonatomic, strong) UIImageView *icon_2;

@property (nonatomic, strong) UILabel *nameLab_2;

@property (nonatomic, strong) UIView *container;

@end

@implementation _SSJDataImportTopView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.titleLab];
        [self addSubview:self.icon_1];
        [self addSubview:self.nameLab_1];
        [self addSubview:self.icon_2];
        [self addSubview:self.nameLab_2];
    }
    return self;
}

- (void)updateConstraints {
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(30);
        make.centerY.mas_equalTo(self);
    }];
    [self.container mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLab.mas_bottom).offset(20);
        make.centerY.mas_equalTo(self);
    }];
    [self.icon_1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(self.container);
    }];
    [self.nameLab_1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.icon_1.mas_bottom).offset(10);
        make.bottom.mas_equalTo(self.container);
        make.centerY.mas_equalTo(self.icon_1);
    }];
    [self.icon_2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.icon_1);
        make.left.mas_equalTo(self.icon_1.mas_right).offset(90);
        make.right.mas_equalTo(self.container);
    }];
    [self.nameLab_2 mas_makeConstraints:^(MASConstraintMaker *make) {
        
    }];
    [super updateConstraints];
}

- (void)updateAppearance {
    
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.text = @"导入其它记账app数据，开启新的记账之旅";
        _titleLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
    }
    return _titleLab;
}

- (UIView *)container {
    if (!_container) {
        _container = [[UIView alloc] init];
        [_container addSubview:self.icon_1];
        [_container addSubview:self.nameLab_1];
        [_container addSubview:self.icon_2];
        [_container addSubview:self.nameLab_2];
    }
    return _container;
}

- (UIImageView *)icon_1 {
    if (!_icon_1) {
        _icon_1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"suishouji_logo"]];
    }
    return _icon_1;
}

- (UILabel *)nameLab_1 {
    if (!_nameLab_1) {
        _nameLab_1 = [[UILabel alloc] init];
        _nameLab_1.text = @"随手记";
        _nameLab_1.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
    }
    return _nameLab_1;
}

- (UIImageView *)icon_2 {
    if (!_icon_2) {
        _icon_2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"custom_logo"]];
    }
    return _icon_2;
}

- (UILabel *)nameLab_2 {
    if (!_nameLab_2) {
        _nameLab_2 = [[UILabel alloc] init];
        _nameLab_2.text = @"自定义";
        _nameLab_2.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
    }
    return _nameLab_2;
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - _SSJDataImportBottomView
#pragma mark -
@interface _SSJDataImportBottomView : UIView

@end

@implementation _SSJDataImportBottomView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - SSJDataImportViewController
#pragma mark -
@interface SSJDataImportViewController ()

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) _SSJDataImportTopView *topView;

@property (nonatomic, strong) _SSJDataImportBottomView *bottomView;

@end

@implementation SSJDataImportViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"数据导入";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
}

@end
