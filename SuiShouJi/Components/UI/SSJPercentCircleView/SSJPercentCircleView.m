//
//  SSJReportFormsPercentCircle.m
//  SuiShouJi
//
//  Created by old lang on 15/12/28.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJPercentCircleView.h"
#import "SSJPercentCircleNode.h"
#import "SSJPercentCircleAdditionNode.h"
#import "SSJPercentCircleAdditionGroupNode.h"

@interface SSJPercentCircleView ()

@property (nonatomic) UIEdgeInsets circleInsets;

@property (nonatomic) CGFloat circleThickness;

@property (nonatomic) CGRect circleFrame;

@property (nonatomic, strong) SSJPercentCircleNode *circleNode;

@property (nonatomic, strong) SSJPercentCircleAdditionGroupNode *additionGroupNode;

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) UIImageView *skinView;

@property (nonatomic) NSUInteger animateCounter;

@property (nonatomic) BOOL reloadFailedCauseByEmptyFrame;

@property (nonatomic, strong) UILabel *topTitleLab;

@property (nonatomic, strong) UILabel *bottomTitleLab;

@end

@implementation SSJPercentCircleView

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame insets:UIEdgeInsetsZero thickness:0];
}

- (instancetype)initWithFrame:(CGRect)frame insets:(UIEdgeInsets)insets thickness:(CGFloat)thickness {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.circleInsets = insets;
        self.circleThickness = thickness;
        self.addtionTextFont = [UIFont systemFontOfSize:12];
        
        self.contentView = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:self.contentView];
        
        self.additionGroupNode = [SSJPercentCircleAdditionGroupNode node];
        [self.contentView addSubview:self.additionGroupNode];
        
        _topTitleLab = [[UILabel alloc] init];
        _topTitleLab.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_topTitleLab];
        
        _bottomTitleLab = [[UILabel alloc] init];
        _bottomTitleLab.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_bottomTitleLab];
        
        self.skinView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.skinView.hidden = YES;
        [self addSubview:self.skinView];
        
        [self updateCircleFrame];
    }
    return self;
}

- (void)layoutSubviews {
    self.contentView.frame = self.bounds;
    [self updateCircleFrame];
    [self layoutTitleLabels];
    
    if (_reloadFailedCauseByEmptyFrame) {
        [self reloadData];
    }
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    self.contentView.backgroundColor = backgroundColor;
}

- (void)setGapBetweenTitles:(CGFloat)gapBetweenTitles {
    if (_gapBetweenTitles != gapBetweenTitles) {
        _gapBetweenTitles = gapBetweenTitles;
        [self setNeedsLayout];
    }
}

- (void)setTopTitle:(NSString *)topTitle {
    if (![_topTitle isEqualToString:topTitle]) {
        _topTitle = topTitle;
        _topTitleLab.text = _topTitle;
        [self setNeedsLayout];
    }
}

- (void)setBottomTitle:(NSString *)bottomTitle {
    if (![_bottomTitle isEqualToString:bottomTitle]) {
        _bottomTitle = bottomTitle;
        _bottomTitleLab.text = _bottomTitle;
        [self setNeedsLayout];
    }
}

- (void)setTopTitleAttribute:(NSDictionary *)topTitleAttribute {
    if (![_topTitleAttribute isEqualToDictionary:topTitleAttribute]) {
        _topTitleAttribute = topTitleAttribute;
        _topTitleLab.font = topTitleAttribute[NSFontAttributeName];
        _topTitleLab.textColor = topTitleAttribute[NSForegroundColorAttributeName];
        [self setNeedsLayout];
    }
}

- (void)setBottomTitleAttribute:(NSDictionary *)bottomTitleAttribute {
    if (![_bottomTitleAttribute isEqualToDictionary:bottomTitleAttribute]) {
        _bottomTitleAttribute = bottomTitleAttribute;
        _bottomTitleLab.font = bottomTitleAttribute[NSFontAttributeName];
        _bottomTitleLab.textColor = bottomTitleAttribute[NSForegroundColorAttributeName];
        [self setNeedsLayout];
    }
}

- (void)reloadData {

    if (!self.dataSource
        || ![self.dataSource respondsToSelector:@selector(numberOfComponentsInPercentCircle:)]
        || ![self.dataSource respondsToSelector:@selector(percentCircle:itemForComponentAtIndex:)]
        || self.circleThickness <= 0) {
        return;
    }
    
    if (CGRectIsEmpty(self.bounds)
        || CGRectIsEmpty(self.circleFrame)) {
        _reloadFailedCauseByEmptyFrame = YES;
        return;
    }
    
    _reloadFailedCauseByEmptyFrame = NO;
    
    self.skinView.hidden = YES;
    
    NSUInteger numberOfComponents = [self.dataSource numberOfComponentsInPercentCircle:self];
    CGFloat overlapScale = 0;
    
    if (!self.circleNode) {
        CGPoint center = CGPointMake(CGRectGetMidX(self.circleFrame), CGRectGetMidY(self.circleFrame));
        CGFloat radius = CGRectGetWidth(self.circleFrame) * 0.5 - self.circleThickness * 0.5;
        CGFloat lineWith = self.circleThickness;
        self.circleNode = [SSJPercentCircleNode nodeWithCenter:center radius:radius lineWith:lineWith];
        [self.contentView addSubview:self.circleNode];
    }
    
    NSMutableArray *circleNodeItems = [NSMutableArray arrayWithCapacity:numberOfComponents];
    NSMutableArray *additionNodeItems = [NSMutableArray array];
    
    for (NSUInteger idx = 0; idx < numberOfComponents; idx ++) {
        
        if ([self.dataSource respondsToSelector:@selector(percentCircle:itemForComponentAtIndex:)]) {
            SSJPercentCircleViewItem *item = [self.dataSource percentCircle:self itemForComponentAtIndex:idx];
            if (!item) {
                return;
            }
            
            item.previousScale = overlapScale;
            
            SSJPercentCircleNodeItem *circleNodeItem = [[SSJPercentCircleNodeItem alloc] init];
            circleNodeItem.startAngle = overlapScale * M_PI * 2;
            circleNodeItem.endAngle = (overlapScale + item.scale) * M_PI * 2;
            circleNodeItem.colorValue = item.colorValue;
            [circleNodeItems addObject:circleNodeItem];
            
            overlapScale += item.scale;
            
            //  添加附加视图(折线、图片、比例)
            SSJPercentCircleAdditionNodeItem *additionViewItem = [[SSJPercentCircleAdditionNodeItem alloc] init];
            
            //  根据比例计算出角度，再根据角度计算出折现的起点
            CGFloat angle = (0.5 * item.scale + item.previousScale) * M_PI * 2 + M_PI * 1.5;
            CGFloat axisX = cos(angle) * CGRectGetWidth(self.circleFrame) * 0.5 + CGRectGetMidX(self.circleFrame);
            CGFloat axisY = sin(angle) * CGRectGetWidth(self.circleFrame) * 0.5 + CGRectGetMidY(self.circleFrame);
            
            additionViewItem.startPoint = CGPointMake(axisX, axisY);
            additionViewItem.angle = angle;
            additionViewItem.lineLength = 20;
            additionViewItem.imageName = item.imageName;
            additionViewItem.customView = item.customView;
            additionViewItem.imageRadius = 13;
            additionViewItem.imageBorderShowed = item.imageBorderShowed;
            additionViewItem.borderColorValue = item.colorValue;
            additionViewItem.gapBetweenImageAndText = 0;
            additionViewItem.text = item.additionalText;
            additionViewItem.font = item.additionalFont ?: self.addtionTextFont;
            additionViewItem.textColorValue = SSJ_CURRENT_THEME.secondaryColor;
            [additionNodeItems addObject:additionViewItem];
        }
    }
    
    self.contentView.hidden = NO;
//    [self.circleNode stopAnimation];
    [self.additionGroupNode cleanUpAdditionNodes];
    
    self.animateCounter ++;
    
    __weak typeof(self) weakSelf = self;
    [self.circleNode setItems:circleNodeItems completion:^{
        [weakSelf.additionGroupNode setItems:additionNodeItems completion:^{
            weakSelf.animateCounter --;
            if (weakSelf.animateCounter > 0 || numberOfComponents == 0) {
                return;
            }
            
            //  渲染成图片，铺在表面上，隐藏其它的界面元素，以提高流畅度
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                UIImage *screentShot = [weakSelf ssj_takeScreenShotWithSize:weakSelf.size opaque:NO scale:0];
//                [UIImagePNGRepresentation(screentShot) writeToFile:@"/Users/oldlang/Desktop/screenshot/test.png" atomically:YES];
                dispatch_sync(dispatch_get_main_queue(), ^{
                    weakSelf.skinView.hidden = NO;
                    weakSelf.skinView.image = screentShot;
                    weakSelf.skinView.size = screentShot.size;
                    
                    weakSelf.contentView.hidden = YES;
                });
            });
        }];
    }];
}

- (void)updateCircleFrame {
    CGRect circleFrame = UIEdgeInsetsInsetRect(self.bounds, self.circleInsets);
    CGFloat circleDiam = MIN(circleFrame.size.width, circleFrame.size.height);
    self.circleFrame = CGRectMake((self.width - circleDiam) * 0.5, circleFrame.origin.y, circleDiam, circleDiam);
}

- (void)layoutTitleLabels {
    [_topTitleLab sizeToFit];
    [_bottomTitleLab sizeToFit];
    
    CGRect innerCircleFrame = UIEdgeInsetsInsetRect(_circleFrame, UIEdgeInsetsMake(_circleThickness, _circleThickness, _circleThickness, _circleThickness));
    
    CGFloat obliqueLength = CGRectGetWidth(innerCircleFrame) * 0.5; // 斜边
    CGFloat edgeLenth_1 = (_topTitleLab.height + _bottomTitleLab.height + _gapBetweenTitles) * 0.5; // 对边
    CGFloat edgeLenth_2 = floor(sqrt(obliqueLength * obliqueLength - edgeLenth_1 * edgeLenth_1));
    
    CGFloat left = CGRectGetMinX(innerCircleFrame) + obliqueLength - edgeLenth_2;
    CGFloat top = CGRectGetMinY(innerCircleFrame) + obliqueLength - edgeLenth_1;
    
    _topTitleLab.frame = CGRectMake(left, top, edgeLenth_2 * 2, _topTitleLab.height);
    _bottomTitleLab.frame = CGRectMake(left, _topTitleLab.bottom + _gapBetweenTitles, edgeLenth_2 * 2, _bottomTitleLab.height);
}

@end
