//
//  SSJReportFormsCurveCell.m
//  SSJCurveGraphView
//
//  Created by old lang on 16/12/16.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJReportFormsCurveCell.h"
#import "SSJReportFormsCurveView.h"

#pragma mark - SSJReportFormsCurveCellItem
#pragma mark -
@implementation SSJReportFormsCurveCellItem

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@:%@", self, @{@"title":_title ?: [NSNull null],
                                                        @"titleFont":_titleFont ?: [NSNull null],
                                                        @"titleColor":_titleColor ?: [NSNull null],
                                                        @"scaleColor":_scaleColor ?: [NSNull null],
                                                        @"scaleTop":@(_scaleTop),
                                                        @"curveItems":[_curveItems debugDescription]}];
}

@end

#pragma mark - SSJReportFormsCurveCell
#pragma mark -

@interface SSJReportFormsCurveCell ()

@property (nonatomic, strong) NSMutableArray<SSJReportFormsCurveView *> *curveViews;

@property (nonatomic, strong) UIView *scale;

@property (nonatomic, strong) UILabel *titleLab;

@end

@implementation SSJReportFormsCurveCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        _curveViews = [[NSMutableArray alloc] init];
        
        _scale = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 4)];
        [self.contentView addSubview:_scale];
        
        _titleLab = [[UILabel alloc] init];
        [self.contentView addSubview:_titleLab];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    for (SSJReportFormsCurveView *curveView in _curveViews) {
        curveView.frame = self.bounds;
    }
    
    _scale.leftTop = CGPointMake(self.contentView.width, _cellItem.scaleTop);
    
    [_titleLab sizeToFit];
    _titleLab.top = _scale.bottom + 8;
    _titleLab.centerX = self.contentView.width;
}

- (void)setCellItem:(SSJReportFormsCurveCellItem *)cellItem {
    _cellItem = cellItem;
    
//    if (_curveViews.count == _cellItem.curveItems.count) {
//        for (int i = 0; i < _cellItem.curveItems.count; i ++) {
//            SSJReportFormsCurveViewItem *item = _cellItem.curveItems[i];
//            SSJReportFormsCurveView *curveView = _curveViews[i];
//            curveView.item = item;
//        }
//    } else {
//        [_curveViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
//        [_curveViews removeAllObjects];
//        
//        for (SSJReportFormsCurveViewItem *item in _cellItem.curveItems) {
//            SSJReportFormsCurveView *curveView = [[SSJReportFormsCurveView alloc] init];
//            curveView.item = item;
//            [self addSubview:curveView];
//            [_curveViews addObject:curveView];
//        }
//    }
    
    [_curveViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_curveViews removeAllObjects];
    
    for (SSJReportFormsCurveViewItem *item in _cellItem.curveItems) {
        SSJReportFormsCurveView *curveView = [[SSJReportFormsCurveView alloc] init];
        curveView.item = item;
        [self addSubview:curveView];
        [_curveViews addObject:curveView];
    }
    
    _scale.backgroundColor = _cellItem.scaleColor;
    
    _titleLab.text = _cellItem.title;
    _titleLab.textColor = _cellItem.titleColor;
    _titleLab.font = _cellItem.titleFont;
    
    [self setNeedsLayout];
}

@end
