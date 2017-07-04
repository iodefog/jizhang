//
//  SSJListMenuCell.m
//  SuiShouJi
//
//  Created by old lang on 16/7/30.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJListMenuCell.h"

@implementation SSJListMenuCell

- (void)dealloc {
    [self removeObserver];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.appliesTheme = NO;
        self.contentView.backgroundColor = [UIColor clearColor];
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.adjustsFontSizeToFitWidth = YES;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    SSJListMenuCellItem *item = (SSJListMenuCellItem *)self.cellItem;
    
    if (!CGSizeEqualToSize(item.imageSize, CGSizeZero)) {
        self.imageView.size = item.imageSize;
    } else {
        [self.imageView sizeToFit];
    }
    
    [self.textLabel sizeToFit];
    
    CGRect contentFrame = UIEdgeInsetsInsetRect(self.contentView.bounds, item.contentInset);
    
    if (CGSizeEqualToSize(self.imageView.size, CGSizeZero)) {
        switch (item.contentAlignment) {
            case UIControlContentHorizontalAlignmentCenter: {
                self.textLabel.centerX = CGRectGetMidX(contentFrame);
            }
                break;
                
            case UIControlContentHorizontalAlignmentLeft: {
                self.textLabel.left = CGRectGetMinX(contentFrame);
            }
                break;
                
            case UIControlContentHorizontalAlignmentRight: {
                self.textLabel.left = CGRectGetMaxX(contentFrame);
            }
                break;
                
            case UIControlContentHorizontalAlignmentFill:
                
                break;
        }
    } else {
        switch (item.contentAlignment) {
            case UIControlContentHorizontalAlignmentCenter: {
                CGFloat left = (CGRectGetWidth(contentFrame) - self.imageView.width - self.textLabel.width - item.gapBetweenImageAndTitle) * 0.5;
                self.imageView.left = CGRectGetMinX(contentFrame) + left;
                self.textLabel.left = self.imageView.right + item.gapBetweenImageAndTitle;
            }
                break;
                
            case UIControlContentHorizontalAlignmentLeft: {
                self.imageView.left = CGRectGetMinX(contentFrame);
                self.textLabel.left = self.imageView.right + item.gapBetweenImageAndTitle;
            }
                break;
                
            case UIControlContentHorizontalAlignmentRight: {
                self.textLabel.right = CGRectGetMaxX(contentFrame);
                self.imageView.right = self.textLabel.left - item.gapBetweenImageAndTitle;
            }
                break;
                
            case UIControlContentHorizontalAlignmentFill:
                
                break;
        }
    }
    
    self.imageView.centerY = self.textLabel.centerY = CGRectGetMidY(contentFrame);
}

- (void)setCellItem:(SSJBaseCellItem *)cellItem {
    if (![cellItem isKindOfClass:[SSJListMenuCellItem class]]) {
        return;
    }
    
    [self removeObserver];
    [super setCellItem:cellItem];
    [self addObserver];
    [self updateAppearance];
}

- (void)updateAppearance {
    
    SSJListMenuCellItem *item = (SSJListMenuCellItem *)self.cellItem;
    
    if (item.imageName) {
        self.imageView.image = [[UIImage imageNamed:item.imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    self.imageView.tintColor = item.imageColor;
    
    self.textLabel.text = item.title;
    self.textLabel.textColor = item.titleColor;
    if (item.attributeStr.length) {
        self.textLabel.attributedText = item.attributeStr;
    }
    self.textLabel.font = item.titleFont;
    self.backgroundColor = item.backgroundColor;
    
    [self setNeedsLayout];
}

- (void)addObserver {
    [self.cellItem addObserver:self forKeyPath:@"imageName" options:NSKeyValueObservingOptionNew context:NULL];
    [self.cellItem addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
    [self.cellItem addObserver:self forKeyPath:@"titleColor" options:NSKeyValueObservingOptionNew context:NULL];
    [self.cellItem addObserver:self forKeyPath:@"imageColor" options:NSKeyValueObservingOptionNew context:NULL];
    [self.cellItem addObserver:self forKeyPath:@"backgroundColor" options:NSKeyValueObservingOptionNew context:NULL];
    [self.cellItem addObserver:self forKeyPath:@"attributeStr" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)removeObserver {
    [self.cellItem removeObserver:self forKeyPath:@"imageName"];
    [self.cellItem removeObserver:self forKeyPath:@"title"];
    [self.cellItem removeObserver:self forKeyPath:@"titleColor"];
    [self.cellItem removeObserver:self forKeyPath:@"imageColor"];
    [self.cellItem removeObserver:self forKeyPath:@"backgroundColor"];
    [self.cellItem removeObserver:self forKeyPath:@"attributeStr"];
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSString*, id> *)change context:(nullable void *)context {
    [self updateAppearance];
}

@end
