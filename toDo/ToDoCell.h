//
//  ToDoCell.h
//  toDo
//
//  Created by Rebekah Baker on 3/9/17.
//  Copyright © 2017 Rebekah Baker. All rights reserved.
//

#import <UIKit/UIKit.h>


@class ToDoItem;

@interface ToDoCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *toDoLbl;
@property (weak, nonatomic) IBOutlet UIButton *checkBtn;
@property BOOL completed;
@property(nonatomic) NSInteger itemID;
- (void)updateUI:(nonnull ToDoItem*)toDoItem;
@end
