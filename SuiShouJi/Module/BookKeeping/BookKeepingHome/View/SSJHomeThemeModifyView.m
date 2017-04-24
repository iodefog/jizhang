//
//  SSJHomeThemeModifyView.m
//  SuiShouJi
//
//  Created by ricky on 2017/4/24.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJHomeThemeModifyView.h"

@interface SSJHomeThemeModifyView() <UICollectionViewDelegate,UICollectionViewDataSource>

@property(nonatomic, strong) UICollectionView  *collectionView;

@end

@implementation SSJHomeThemeModifyView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

-(UICollectionView *)collectionView{
    if (_collectionView==nil) {
        UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc]init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.minimumLineSpacing = 20;
        _collectionView=[[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.delegate=self;
        _collectionView.dataSource=self;
        _collectionView.backgroundColor = [UIColor clearColor];
    }
    return _collectionView;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
