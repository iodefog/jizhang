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
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)setCellItem:(SSJBaseItem *)cellItem {
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
    self.imageView.image = [UIImage imageNamed:item.imageName];
    self.textLabel.text = item.title;
    self.textLabel.textColor = item.titleColor;
}

- (void)addObserver {
    [self.cellItem addObserver:self forKeyPath:@"imageName" options:NSKeyValueObservingOptionNew context:NULL];
    [self.cellItem addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
    [self.cellItem addObserver:self forKeyPath:@"titleColor" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)removeObserver {
    [self.cellItem removeObserver:self forKeyPath:@"imageName"];
    [self.cellItem removeObserver:self forKeyPath:@"title"];
    [self.cellItem removeObserver:self forKeyPath:@"titleColor"];
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSString*, id> *)change context:(nullable void *)context {
    [self updateAppearance];
}

@end
