//
//  LBXWeekTableViewController.h
//  Longboxed-iOS
//
//  Created by johnrhickey on 9/8/14.
//  Copyright (c) 2014 Longboxed. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LBXWeekTableViewController : UITableViewController

// TODO: Delete this property (it's for setting this VC as the root VC)
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (instancetype)initWithDate:(NSDate *)date;
- (instancetype)initWithThisWeek;
- (instancetype)initWithNextWeek;

@end