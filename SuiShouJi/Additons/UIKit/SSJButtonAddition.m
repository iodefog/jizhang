//
//  SSJButtonAddition.m
//  MoneyMore
//
//  Created by old lang on 15-3-24.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "SSJButtonAddition.h"
//#import <objc/runtime.h>

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

static const void *kContentLayoutTypeKey = &kContentLayoutTypeKey;
static const void *kSpaceBetweenImageAndTitleKey = &kSpaceBetweenImageAndTitleKey;

@implementation UIButton (SSJContentLayout)

+ (void)load {
//    SSJSwizzleSelector(self, @selector(setFrame:), @selector(ssj_setFrame:));
    SSJSwizzleSelector(self, @selector(setBounds:), @selector(ssj_setBounds:));
}

//- (void)ssj_setFrame:(CGRect)frame {
//    [self ssj_setFrame:frame];
//    [self ssj_layoutContent];
//}

- (void)ssj_setBounds:(CGRect)bounds {
    [self ssj_setBounds:bounds];
    [self ssj_layoutContent];
}

- (SSJButtonLayoutType)contentLayoutType {
    return [objc_getAssociatedObject(self, kContentLayoutTypeKey) unsignedIntegerValue];
}

- (void)setContentLayoutType:(SSJButtonLayoutType)contentLayoutType {
    SSJButtonLayoutType layout = [self contentLayoutType];
    if (layout != contentLayoutType) {
        objc_setAssociatedObject(self, kContentLayoutTypeKey, @(contentLayoutType), OBJC_ASSOCIATION_RETAIN);
        [self ssj_layoutContent];
    }
}

- (CGFloat)spaceBetweenImageAndTitle {
    return [objc_getAssociatedObject(self, kSpaceBetweenImageAndTitleKey) doubleValue];
}

- (void)setSpaceBetweenImageAndTitle:(CGFloat)spaceBetweenImageAndTitle {
    CGFloat space_1 = [self spaceBetweenImageAndTitle];
    if (space_1 != spaceBetweenImageAndTitle) {
        objc_setAssociatedObject(self, kSpaceBetweenImageAndTitleKey, @(spaceBetweenImageAndTitle), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self ssj_layoutContent];
    }
}

- (void)ssj_layoutContent {
    UIImage *image = [self imageForState:UIControlStateNormal];
    if (!image || !self.titleLabel.text) {
        return;
    }
    
    CGSize imageSize = image.size;
    CGSize titleSize = [self.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:self.titleLabel.font}];
    CGFloat space = [self spaceBetweenImageAndTitle];
    
    SSJButtonLayoutType layoutType = [self contentLayoutType];
    
    switch (layoutType) {
        case SSJButtonLayoutTypeDefault: {
            CGFloat image_left = (self.width - titleSize.width - imageSize.width) * 0.5 - space * 0.5;
            CGFloat image_right = self.width - (image_left + imageSize.width);
            [self setImageEdgeInsets:UIEdgeInsetsMake(0, image_left, 0, image_right)];
            
            CGFloat title_left = (self.width - titleSize.width - imageSize.width) * 0.5 + space * 0.5;
            CGFloat title_right = self.width - (title_left + titleSize.width) - imageSize.width;
            [self setTitleEdgeInsets:UIEdgeInsetsMake(0, title_left, 0, title_right)];
        }   break;
            
        case SSJButtonLayoutTypeImageRightTitleLeft: {
            CGFloat image_left = (self.width - titleSize.width - imageSize.width) * 0.5 + titleSize.width + space * 0.5;
            CGFloat image_right = self.width - (image_left + imageSize.width);
            [self setImageEdgeInsets:UIEdgeInsetsMake(0, image_left, 0, image_right)];
            
            CGFloat title_left = (self.width - titleSize.width - imageSize.width) * 0.5 - imageSize.width - space * 0.5;
            CGFloat title_right = self.width - (title_left + titleSize.width) - imageSize.width;
            [self setTitleEdgeInsets:UIEdgeInsetsMake(0, title_left, 0, title_right)];
        }   break;
            
        case SSJButtonLayoutTypeImageTopTitleBottom: {
            CGFloat image_left = (self.width - imageSize.width) * 0.5;
            CGFloat image_right = image_left;
            CGFloat image_top = (self.height - imageSize.height - titleSize.height - space) * 0.5;
            CGFloat image_bottom = self.height - image_top - imageSize.height;
            [self setImageEdgeInsets:UIEdgeInsetsMake(image_top, image_left, image_bottom, image_right)];
            
            CGFloat title_left = (self.width - titleSize.width - imageSize.width) * 0.5 - imageSize.width * 0.5;
            CGFloat title_right = (self.width - titleSize.width - imageSize.width) * 0.5 + imageSize.width * 0.5;
            CGFloat title_top = image_top + imageSize.height + space;
            CGFloat title_bottom = self.height - title_top - titleSize.height;
            [self setTitleEdgeInsets:UIEdgeInsetsMake(title_top, title_left, title_bottom, title_right)];
        }   break;
            
        case SSJButtonLayoutTypeImageBottomTitleTop: {
            CGFloat title_left = (self.width - titleSize.width - imageSize.width) * 0.5 - imageSize.width * 0.5;
            CGFloat title_right = (self.width - titleSize.width - imageSize.width) * 0.5 + imageSize.width * 0.5;
            CGFloat title_top = (self.height - imageSize.height - titleSize.height - space) * 0.5;
            CGFloat title_bottom = self.height - title_top - titleSize.height;
            [self setTitleEdgeInsets:UIEdgeInsetsMake(title_top, title_left, title_bottom, title_right)];
            
            CGFloat image_left = (self.width - imageSize.width) * 0.5;
            CGFloat image_right = image_left;
            CGFloat image_top = title_top + titleSize.height + space;
            CGFloat image_bottom = self.height - image_top - imageSize.height;
            [self setImageEdgeInsets:UIEdgeInsetsMake(image_top, image_left, image_bottom, image_right)];
        }   break;
    }
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

@implementation UIButton (SSJBackgroundColor)

- (void)ssj_setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state {
    [self setBackgroundImage:[UIImage ssj_imageWithColor:backgroundColor size:self.size] forState:state];
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
