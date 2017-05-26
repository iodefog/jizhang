//
//  SSJBudgetCategorySelectionControl.m
//  SuiShouJi
//
//  Created by old lang on 16/12/5.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBudgetCategorySelectionControl.h"

@interface SSJBudgetCategorySelectionControl ()

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) SSJListMenu *listMenu;

@end

@implementation SSJBudgetCategorySelectionControl

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.imageView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        [self addGestureRecognizer:tap];
        
        [self sizeToFit];
        [self updateAppearance];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(55, 40);
}

- (void)layoutSubviews {
    self.imageView.center = CGPointMake(self.width * 0.7, self.height * 0.5);
}

- (void)setOption:(SSJBudgetCategorySelectionControlOption)option {
    switch (option) {
        case SSJBudgetCategorySelectionControlOptionMajor:
            self.listMenu.selectedIndex = 0;
            break;
            
        case SSJBudgetCategorySelectionControlOptionSecondary:
            self.listMenu.selectedIndex = 1;
            break;
    }
}

- (void)updateAppearance {
    self.imageView.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
    [self.listMenu updateAppearance];
    for (SSJListMenuItem *item in self.listMenu.items) {
        item.normalTitleColor = SSJ_MAIN_COLOR;
        item.normalImageColor = SSJ_SECONDARY_COLOR;
    }
}

- (void)tapAction {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    CGPoint showPoint = [self convertPoint:CGPointMake(self.imageView.centerX, self.bottom) toView:window];
    [self.listMenu showInView:window atPoint:showPoint dismissHandle:^(SSJListMenu *listMenu) {
        [UIView animateWithDuration:0.2 animations:^{
            self.imageView.transform = CGAffineTransformIdentity;
        }];
    }];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.imageView.transform = CGAffineTransformMakeRotation(M_PI_4);
    }];
}

- (void)listMenuSelectAction {
    if (self.listMenu.selectedIndex == 0) {
        _option = SSJBudgetCategorySelectionControlOptionMajor;
        [SSJAnaliyticsManager event:@"budget_total"];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    } else if (self.listMenu.selectedIndex == 1) {
        [SSJAnaliyticsManager event:@"budget_classify"];
        _option = SSJBudgetCategorySelectionControlOptionSecondary;
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    } else {
        
    }
}

- (UIImageView *)imageView {
    if (!_imageView) {
        UIImage *image = [[UIImage imageNamed:@"founds_jia"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _imageView = [[UIImageView alloc] initWithImage:image];
    }
    return _imageView;
}

- (SSJListMenu *)listMenu {
    if (!_listMenu) {
        _listMenu = [[SSJListMenu alloc] init];
        _listMenu.items = @[[SSJListMenuItem itemWithImageName:@"reportForms_category"
                                                         title:@"总预算"
                                              normalTitleColor:SSJ_MAIN_COLOR
                                            selectedTitleColor:nil
                                              normalImageColor:SSJ_SECONDARY_COLOR
                                            selectedImageColor:nil
                                               backgroundColor:SSJ_MAIN_BACKGROUND_COLOR],
                            [SSJListMenuItem itemWithImageName:@"reportForms_member"
                                                         title:@"分类预算"
                                              normalTitleColor:SSJ_MAIN_COLOR
                                            selectedTitleColor:nil
                                              normalImageColor:SSJ_SECONDARY_COLOR
                                            selectedImageColor:nil
                                               backgroundColor:SSJ_MAIN_BACKGROUND_COLOR]];
        _listMenu.width = 124;
        [_listMenu addTarget:self action:@selector(listMenuSelectAction) forControlEvents:UIControlEventValueChanged];
    }
    return _listMenu;
}

@end
