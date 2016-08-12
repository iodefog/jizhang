//
//  SSJReportFormsMemberAndCategorySwitchControl.m
//  SuiShouJi
//
//  Created by old lang on 16/7/30.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJReportFormsMemberAndCategorySwitchControl.h"
#import "SSJListMenu.h"

@interface SSJReportFormsMemberAndCategorySwitchControl ()

@property (nonatomic, strong) UILabel *titleLab;

@property (nonatomic, strong) CAShapeLayer *triangle;

@property (nonatomic, strong) SSJListMenu *listMenu;

@end

@implementation SSJReportFormsMemberAndCategorySwitchControl

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.titleLab];
        [self.layer addSublayer:self.triangle];
        [self updateTitle];
        [self updateAppearance];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)layoutSubviews {
    CGFloat left = (self.width - _titleLab.width - _triangle.width - 3) * 0.5;
    _titleLab.left = left;
    _titleLab.centerY = self.height * 0.5;
    _triangle.left = _titleLab.right + 3;
    _triangle.bottom = _titleLab.bottom - 3;
}

- (void)setOption:(SSJReportFormsMemberAndCategorySwitchControlOption)option {
    _listMenu.selectedIndex = option;
    [self updateTitle];
}

- (void)updateAppearance {
    self.titleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    self.triangle.fillColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor].CGColor;
    self.listMenu.normalTitleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    self.listMenu.selectedTitleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
    self.listMenu.fillColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryFillColor];
    self.listMenu.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
    self.listMenu.imageColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
}

#pragma mark - Action
- (void)tapAction {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    CGPoint showPoint = [self convertPoint:CGPointMake(self.width * 0.5, self.bottom) toView:window];
    [self.listMenu showInView:window atPoint:showPoint dismissHandle:^(SSJListMenu *listMenu) {
        [UIView animateWithDuration:0.2 animations:^{
            _triangle.transform = CATransform3DIdentity;
        }];
    }];
    
    [UIView animateWithDuration:0.2 animations:^{
        _triangle.transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
    }];
}

- (void)listMenuSelectAction {
    _option = _listMenu.selectedIndex;
//    [_listMenu dismiss];
    [self updateTitle];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

#pragma mark - Private
- (NSArray *)listItems {
    SSJListMenuItem *item1 = [[SSJListMenuItem alloc] init];
    item1.imageName = @"reportForms_category";
    item1.title = @"分类";
    
    SSJListMenuItem *item2 = [[SSJListMenuItem alloc] init];
    item2.imageName = @"reportForms_member";
    item2.title = @"成员";
    
    return [NSMutableArray arrayWithObjects:item1, item2, nil];
}

- (void)updateTitle {
    switch (_option) {
        case SSJReportFormsMemberAndCategorySwitchControlOptionCategory:
            _titleLab.text = @"分类";
            break;
            
        case SSJReportFormsMemberAndCategorySwitchControlOptionMember:
            _titleLab.text = @"成员";
            break;
    }
    [_titleLab sizeToFit];
}

#pragma mark - Getter
- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = [UIFont systemFontOfSize:18];
    }
    return _titleLab;
}

- (CAShapeLayer *)triangle {
    if (!_triangle) {
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointZero];
        [path addLineToPoint:CGPointMake(6, 0)];
        [path addLineToPoint:CGPointMake(3, 6)];
        [path closePath];
        
        _triangle = [CAShapeLayer layer];
        _triangle.size = CGSizeMake(6, 6);
        _triangle.path = path.CGPath;
    }
    return _triangle;
}

- (SSJListMenu *)listMenu {
    if (!_listMenu) {
        _listMenu = [[SSJListMenu alloc] initWithItems:[self listItems]];
        _listMenu.size = CGSizeMake(104, 84);
        [_listMenu addTarget:self action:@selector(listMenuSelectAction) forControlEvents:UIControlEventValueChanged];
    }
    return _listMenu;
}

@end
