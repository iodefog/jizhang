require("SSJMineHomeTabelviewCell, NSString");

defineClass("SSJSettingViewController", {
    tableView_numberOfRowsInSection: function(tableView, section) {
        if (section == self.titles().count() + 1) {
            return 1;
        }
        return self.titles().objectAtIndex(section).count();
    },
    numberOfSectionsInTableView: function(tableView) {
        return self.titles().count() + 1;
    },
    tableView_cellForRowAtIndexPath: function(tableView, indexPath) {
        var cellId = "SSJMineHomeCell";
        var mineHomeCell = tableView.dequeueReusableCellWithIdentifier(cellId);
        if (!mineHomeCell) {
            mineHomeCell = SSJMineHomeTabelviewCell.alloc().initWithStyle_reuseIdentifier(0, cellId);
            mineHomeCell.setCustomAccessoryType(1);
        }
        var title = self.titles().ssj__objectAtIndexPath(indexPath);
        if (title.isEqualToString("点击上方微信号复制，接着去微信查找即可")) {
            mineHomeCell.setCustomAccessoryType(0);
            mineHomeCell.setCellSubTitle(title);
        } else if (indexPath.section() == self.titles().count() + 1) {
            mineHomeCell.setCustomAccessoryType(1);
            mineHomeCell.setCellTitle("上传");
        } else {
            mineHomeCell.setCustomAccessoryType(UITableViewCellAccessoryDisclosureIndicator);
            mineHomeCell.setCellTitle(title);
            if (self.titles().ssj__objectAtIndexPath(indexPath).isEqualToString("检查更新")) {
                mineHomeCell.setCellDetail(NSString.stringWithFormat("v%@", SSJAppVersion()));
            } else if (mineHomeCell.cellTitle().isEqualToString(kTitle7)) {
                mineHomeCell.setCellDetail("youyujz");
            }
        }
        return mineHomeCell;
    }
}, {});


