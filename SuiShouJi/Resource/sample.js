require('UIScrollView,SSJBillingChargeCellItem,SSJBudgetDatabaseHelper,UIApplication,SSJBudgetModel,SSJHomeBudgetButton,SSJHomeReminderView,SSJHomeTableView');
defineClass('SSJBookKeepingHomeViewController', {
scrollViewDidScroll: function(scrollView) {
 if (scrollView.contentOffset().y <= -46) {
  var slf = self;
  SSJBudgetDatabaseHelper.queryForCurrentBudgetListWithSuccess_failure(block('NSArray*', function(result) {
    slf.budgetButton().setModel(result.firstObject());
    for (var i = 0; i < result.count(); i++) {
        if (result.objectAtIndex(i).remindMoney() >= result.objectAtIndex(i).budgetMoney() - result.objectAtIndex(i).payMoney() && result.objectAtIndex(i).isRemind() == 1 && result.objectAtIndex(i).isAlreadyReminded() == 0) {
            slf.remindView().setModel(result.objectAtIndex(i));
            UIApplication.sharedApplication().addSubview(slf.remindView());
            break;
        }
    }
  }), block('NSError*', function(error) {

  }));
}
if (scrollView.contentOffset().y < -46) {
        self.tableView().setLineHeight(-scrollView.contentOffset().y);
        if (self.items().count() == 0) {
            self.tableView().setHasData(NO);
        } else {
            self.tableView().setHasData(YES);
        }
         if (!_isRefreshing) {
            self.homeButton().startAnimating();
            _isRefreshing = YES;
        }
    } else {
        _isRefreshing = NO;
        if (self.items().count() == 0) {
            return;
        } else {
            var currentPostion = {x: self.view().frame().width / 2, y:scrollView.contentOffset().y + 46} ;
            var currentRow = self.tableView().indexPathForRowAtPoint(currentPostion).row();
            var item = self.items().objectAtIndex(currentRow);
            var currentMonth = item.billDate().substringWithRange({location: 5, length: 2}).integerValue();
            var currentYear = item.billDate().substringWithRange({location: 0, length: 4}).integerValue();
            if (currentMonth != self.currentMonth() || currentYear != self.currentYear()) {
                self.setCurrentYear(currentYear);
                self.setCurrentMonth(currentMonth);
                self.reloadCurrentMonthData();
              }
        }

    }
},
});
