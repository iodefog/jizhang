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
        [self addSubview:self.listMenu];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(55, 40);
}

- (void)layoutSubviews {
    self.imageView.center = CGPointMake(self.width * 0.5, self.height * 0.5);
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

- (void)tapAction {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    CGPoint showPoint = [self convertPoint:CGPointMake(self.width * 0.5, self.bottom) toView:window];
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
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    } else if (self.listMenu.selectedIndex == 1) {
        _option = SSJBudgetCategorySelectionControlOptionSecondary;
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    } else {
        
    }
}

- (NSArray *)listItems {
    SSJListMenuItem *item1 = [[SSJListMenuItem alloc] init];
    item1.imageName = @"reportForms_category";
    item1.title = @"总预算";
    
    SSJListMenuItem *item2 = [[SSJListMenuItem alloc] init];
    item2.imageName = @"reportForms_member";
    item2.title = @"分类预算";
    
    return [NSMutableArray arrayWithObjects:item1, item2, nil];
}

- (UIImageView *)imageView {
    if (!_imageView) {
        UIImage *image = [[UIImage imageNamed:@"budget_add"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _imageView = [[UIImageView alloc] initWithImage:image];
    }
    return _imageView;
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
