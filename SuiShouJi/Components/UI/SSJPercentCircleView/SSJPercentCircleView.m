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
#import "SSJPercentCircleAdditionNodeComposer.h"

@implementation SSJPercentCircleViewItem

@end


@interface SSJPercentCircleView ()

@property (nonatomic) CGFloat radius;

@property (nonatomic) CGFloat thickness;

@property (nonatomic) CGFloat lineLength1;

@property (nonatomic) CGFloat lineLength2;

@property (nonatomic, strong) SSJPercentCircleNode *circleNode;

@property (nonatomic, strong) SSJPercentCircleAdditionGroupNode *additionGroupNode;

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) UIView *skinView;

@property (nonatomic) NSUInteger animateCounter;

@property (nonatomic) BOOL reloadFailedCauseByEmptyFrame;

@property (nonatomic, strong) UILabel *topTitleLab;

@property (nonatomic, strong) UILabel *bottomTitleLab;

@property (nonatomic, strong) SSJPercentCircleAdditionNodeComposer *composer;

@end

@implementation SSJPercentCircleView

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame
                        radius:0
                     thickness:0
                   lineLength1:0
                   lineLength2:0];
}

- (instancetype)initWithFrame:(CGRect)frame
                       radius:(CGFloat)radius
                    thickness:(CGFloat)thickness
                  lineLength1:(CGFloat)lineLength1
                  lineLength2:(CGFloat)lineLength2 {
    
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.radius = radius;
        self.thickness = thickness;
        self.lineLength1 = lineLength1;
        self.lineLength2 = lineLength2;
        self.addtionTextFont = [UIFont systemFontOfSize:12];
        self.addtionTextColor = [UIColor lightGrayColor];
        
        self.contentView = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:self.contentView];
        
        self.additionGroupNode = [SSJPercentCircleAdditionGroupNode node];
        [self.contentView addSubview:self.additionGroupNode];
        
        self.topTitleLab = [[UILabel alloc] init];
        self.topTitleLab.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.topTitleLab];
        
        self.bottomTitleLab = [[UILabel alloc] init];
        self.bottomTitleLab.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.bottomTitleLab];
        
        self.circleNode = [SSJPercentCircleNode node];
        self.circleNode.radius = self.radius - self.thickness * 0.5;
        self.circleNode.thickness = self.thickness;
        [self.contentView addSubview:self.circleNode];
        
        self.composer = [SSJPercentCircleAdditionNodeComposer composer];
    }
    return self;
}

- (void)layoutSubviews {
    CGFloat length_1 = self.lineLength1 + self.lineLength2;
    CGFloat rangeTop = CGRectGetMidY(self.bounds) - self.radius - length_1;
    CGFloat rangeBottom = CGRectGetMaxY(self.bounds) - rangeTop * 2;
    self.composer.boundary = CGRectMake(10, rangeTop, self.width - 20, rangeBottom);
//    [self setNeedsDisplay];
    
    self.contentView.frame = self.bounds;
    self.circleNode.frame = CGRectMake(self.width * 0.5 - self.radius, self.height * 0.5 - self.radius, self.radius * 2, self.radius * 2);
    self.composer.circleFrame = self.circleNode.frame;
    
    [_topTitleLab sizeToFit];
    [_bottomTitleLab sizeToFit];
    
    CGRect innerCircleFrame = UIEdgeInsetsInsetRect(self.circleNode.frame, UIEdgeInsetsMake(self.thickness, self.thickness, self.thickness, self.thickness));
    
    CGFloat obliqueLength = CGRectGetWidth(innerCircleFrame) * 0.5; // 斜边
    CGFloat edgeLenth_1 = (_topTitleLab.height + _bottomTitleLab.height + _gapBetweenTitles) * 0.5; // 对边
    CGFloat edgeLenth_2 = floor(sqrt(obliqueLength * obliqueLength - edgeLenth_1 * edgeLenth_1));
    
    CGFloat left = CGRectGetMinX(innerCircleFrame) + obliqueLength - edgeLenth_2;
    CGFloat top = CGRectGetMinY(innerCircleFrame) + obliqueLength - edgeLenth_1;
    
    _topTitleLab.frame = CGRectMake(left, top, edgeLenth_2 * 2, _topTitleLab.height);
    _bottomTitleLab.frame = CGRectMake(left, _topTitleLab.bottom + _gapBetweenTitles, edgeLenth_2 * 2, _bottomTitleLab.height);
    
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
        || self.thickness <= 0) {
        return;
    }
    
    if (CGRectIsEmpty(self.bounds)) {
        _reloadFailedCauseByEmptyFrame = YES;
        return;
    }
    
    _reloadFailedCauseByEmptyFrame = NO;
    
    NSUInteger numberOfComponents = [self.dataSource numberOfComponentsInPercentCircle:self];
    NSMutableArray *circleNodeItems = [NSMutableArray arrayWithCapacity:numberOfComponents];
    CGFloat overlapScale = 0;
    
    [self.composer clearItems];
    
    for (NSUInteger idx = 0; idx < numberOfComponents; idx ++) {
        
        if ([self.dataSource respondsToSelector:@selector(percentCircle:itemForComponentAtIndex:)]) {
            SSJPercentCircleViewItem *item = [self.dataSource percentCircle:self itemForComponentAtIndex:idx];
            if (!item) {
                return;
            }
            
            SSJPercentCircleNodeItem *circleNodeItem = [[SSJPercentCircleNodeItem alloc] init];
            circleNodeItem.startAngle = overlapScale * M_PI * 2;
            circleNodeItem.endAngle = (overlapScale + item.scale) * M_PI * 2;
            circleNodeItem.color = item.color;
            [circleNodeItems addObject:circleNodeItem];
            
            // 根据比例计算出角度，再根据角度计算出折现的起点
            CGFloat angle = (0.5 * item.scale + overlapScale) * M_PI * 2 + M_PI * 1.5;
            CGPoint startPoint = CGPointMake(cos(angle) * self.radius + self.width * 0.5, sin(angle) * self.radius + self.height * 0.5);
            CGPoint breakPoint = CGPointMake(cos(angle) * (self.radius + self.lineLength1) + self.width * 0.5, sin(angle) * (self.radius + self.lineLength1) + self.height * 0.5);
            CGPoint endPoint = CGPointZero;
            
            SSJRadianRange range = SSJRadianRangeTop;
            
            if (angle > M_PI * 1.5 && angle < M_PI * 2.5) {
                // 右边
                endPoint = CGPointMake(breakPoint.x + self.lineLength2, breakPoint.y);
                range = SSJRadianRangeRight;
            } else if (angle > M_PI * 2.5 && angle < M_PI * 3.5) {
                // 左边
                endPoint = CGPointMake(breakPoint.x - self.lineLength2, breakPoint.y);
                range = SSJRadianRangeLeft;
            } else if (angle == M_PI * 1.5) {
                // 顶部
                endPoint = CGPointMake(breakPoint.x, breakPoint.y - self.lineLength2);
                range = SSJRadianRangeTop;
            } else if (angle == M_PI * 2.5) {
                // 底部
                endPoint = CGPointMake(breakPoint.x, breakPoint.y + self.lineLength2);
                range = SSJRadianRangeBottom;
            }
            
            // 添加附加视图(折线、图片、比例)
            SSJPercentCircleAdditionNodeItem *additionViewItem = [[SSJPercentCircleAdditionNodeItem alloc] init];
            additionViewItem.range = range;
            additionViewItem.startPoint = startPoint;
            additionViewItem.breakPoint = breakPoint;
            additionViewItem.endPoint = endPoint;
            additionViewItem.borderColor = item.color;
            additionViewItem.text = item.text;
            additionViewItem.font = self.addtionTextFont;
            additionViewItem.textColor = self.addtionTextColor;
            [self.composer addNodeItem:additionViewItem];
            
            overlapScale += item.scale;
        }
    }
    
    NSArray *additionNodeItems = [self.composer composeNodeItems];
    
    self.contentView.hidden = NO;
    [self.skinView removeFromSuperview];
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
            
            // 渲染成图片，铺在表面上，隐藏其它的界面元素，以提高流畅度
            weakSelf.skinView = [weakSelf.contentView snapshotViewAfterScreenUpdates:YES];
            [weakSelf addSubview:weakSelf.skinView];
            weakSelf.contentView.hidden = YES;
        }];
    }];
}

#warning test
- (void)drawRect:(CGRect)rect {
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
//    CGContextMoveToPoint(ctx, CGRectGetMinX(self.composer.boundary), CGRectGetMinY(self.composer.boundary));
//    CGContextAddLineToPoint(ctx, CGRectGetMaxX(self.composer.boundary), CGRectGetMinY(self.composer.boundary));
//    CGContextMoveToPoint(ctx, CGRectGetMinX(self.composer.boundary), CGRectGetMaxY(self.composer.boundary));
//    CGContextAddLineToPoint(ctx, CGRectGetMaxX(self.composer.boundary), CGRectGetMaxY(self.composer.boundary));
//    CGContextStrokePath(ctx);
    
    [[UIColor redColor] setStroke];
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.composer.boundary];
    [path stroke];
}

@end
