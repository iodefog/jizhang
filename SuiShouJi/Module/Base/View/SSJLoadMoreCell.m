//
//  SSJLoadMoreCell.m
//  MoneyMore
//
//  Created by old lang on 15-3-24.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "SSJLoadMoreCell.h"

@interface SSJLoadMoreCell () {
    UIActivityIndicatorView *_indicatorView;
}

@end

@implementation SSJLoadMoreCell

- (void)dealloc{
    [_indicatorView stopAnimating];
}

+ (CGFloat)tableView:(UITableView *)tableView rowHeightForObject:(id)object {
    return 48;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.contentView addSubview:_indicatorView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize size = self.bounds.size;
    CGFloat space = 2.0f;
    CGFloat textWidth = 0;
    
    NSString *text = self.textLabel.text;
    if(text) {
        CGRect textRect =[text boundingRectWithSize:CGSizeMake(size.width, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.textLabel.font} context:nil];
        textWidth = MIN(size.width / 2.0f, textRect.size.width);
    }
    
    CGFloat totalWidth = _indicatorView.width + textWidth + space;
    CGFloat startX = (size.width - totalWidth) / 2.0f;
    _indicatorView.left = startX;
    
    self.textLabel.frame = CGRectMake(_indicatorView.right + space, _indicatorView.top, textWidth + space, _indicatorView.height);
    [self.textLabel sizeToFit];
    
    _indicatorView.centerY = self.textLabel.centerY = size.height / 2.0f;
    [_indicatorView startAnimating];
}

- (void)setCellItem:(SSJBaseCellItem *)cellItem {
    [super setCellItem:cellItem];
    
    SSJLoadMoreItem *loadMoreItem = (SSJLoadMoreItem *)cellItem;
    self.textLabel.text = loadMoreItem.loadingTitle;
}

@end
