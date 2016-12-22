//
//  SSJReportFormCanYinChartCell.h
//  SuiShouJi
//
//  Created by yi cai on 2016/12/22.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseTableViewCell.h"

@interface SSJReportFormCanYinChartCell : SSJBaseTableViewCell
/**
 圆圈颜色：第一层直径20px 30%  第二层直径14px 30%   中间最小的点实色 直径8px
 */
@property (nonatomic, copy) NSString *imageColor;
//返回cell
+ (SSJReportFormCanYinChartCell *)cellWithTableView:(UITableView *)tableView;

//判断是否是第一个或者最后一个cell
- (void)tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;
@end
