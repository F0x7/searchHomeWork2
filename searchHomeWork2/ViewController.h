//
//  ViewController.h
//  searchHomeWork2
//
//  Created by Fox Lis on 09.10.15.
//  Copyright © 2015 Egor Bakaykin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController 


@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@end

