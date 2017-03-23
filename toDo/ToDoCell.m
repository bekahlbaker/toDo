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
#import "RoundedView.h"

@interface ToDoCell()
@property (weak, nonatomic) IBOutlet UILabel *toDoLbl;
@property BOOL completed;
@property(nonatomic) NSInteger itemID;
@property (weak, nonatomic) IBOutlet UIButton *checkBtn;
- (IBAction)checkBtnTapped:(id)sender;
@property (weak, nonatomic) IBOutlet RoundedView *backgroundView;

@end

@implementation ToDoCell
@dynamic backgroundView;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)updateUI:(nonnull ToDoItem*)toDoItem {
    self.toDoLbl.text = toDoItem.toDoListItem;
    self.completed = toDoItem.completed;
    self.itemID = toDoItem.itemID;
    
    if (self.completed == 0) {
        [self.checkBtn setImage:[UIImage imageNamed:@"empty"] forState:UIControlStateNormal];
        self.backgroundView.backgroundColor = [UIColor whiteColor];
    } else {
        [self.checkBtn setImage:[UIImage imageNamed:@"check"] forState:UIControlStateNormal];
        self.backgroundView.backgroundColor = [UIColor grayColor];
    }
}


- (IBAction)checkBtnTapped:(id)sender {
    NSLog(@"Btn tapped! %ld", (long)self.checkBtn.tag);
    if (self.completed == 0) {
        [[HTTPService instance]checkItemDone:(self.itemID) completionHandler:^(NSArray * _Nullable dataArray, NSString * _Nullable errMessage) {
            NSLog(@"Completed item!");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"downloadData" object:self];
        }];
    } else {
        [[HTTPService instance]checkItemNotDone:(self.itemID) completionHandler:^(NSArray * _Nullable dataArray, NSString * _Nullable errMessage) {
            NSLog(@"Have not completed item!");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"downloadData" object:self];
        }];
    }
    
}
@end
