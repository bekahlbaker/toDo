//
//  ToDoCell.m
//  toDo
//
//  Created by Rebekah Baker on 3/9/17.
//  Copyright © 2017 Rebekah Baker. All rights reserved.
//

#import "ToDoCell.h"
#import "ToDoItem.h"
#import "HTTPService.h"

@interface ToDoCell()
@property (weak, nonatomic) IBOutlet UILabel *toDoLbl;
@property BOOL completed;
@property(nonatomic) NSInteger itemID;
@property (weak, nonatomic) IBOutlet UIButton *checkBtn;
- (IBAction)checkBtnTapped:(id)sender;

@end

@implementation ToDoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)updateUI:(nonnull ToDoItem*)toDoItem {
    self.toDoLbl.text = toDoItem.toDoListItem;
    self.completed = toDoItem.completed;
    self.itemID = toDoItem.itemID;
    
    if (self.completed == 0) {
      [self.checkBtn setTitle:@"Not Done" forState:UIControlStateNormal];
    } else {
        [self.checkBtn setTitle:@"Done" forState:UIControlStateNormal];
    }
}

- (IBAction)checkBtnTapped:(id)sender {
    if (self.completed == 0) {
        [[HTTPService instance]checkItemDone:(self.itemID) completionHandler:^(NSArray * _Nullable dataArray, NSString * _Nullable errMessage) {
            NSLog(@"Completed item!");

        }];
    }
}
@end
