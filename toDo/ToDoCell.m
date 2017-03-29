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
#import "ViewController.h"

@interface ToDoCell()
- (IBAction)checkBtnTapped:(id)sender;
@property (weak, nonatomic) IBOutlet RoundedView *roundedView;
@end

@implementation ToDoCell


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)updateUI:(nonnull ToDoItem*)toDoItem {
    NSLog(@"#3 UPDATING UI");
    self.toDoLbl.text = toDoItem.toDoListItem;
    self.completed = toDoItem.completed;
    self.itemID = toDoItem.itemID;
    
    if (self.completed == 0) {
        [self.checkBtn setImage:[UIImage imageNamed:@"Check-Empty"] forState:UIControlStateNormal];
        self.roundedView.backgroundColor = [UIColor whiteColor];
    } else {
        [self.checkBtn setImage:[UIImage imageNamed:@"Check"] forState:UIControlStateNormal];
        self.roundedView.backgroundColor = [UIColor colorWithRed:0.87 green:0.84 blue:0.82 alpha:1.0];
    }
}


- (IBAction)checkBtnTapped:(id)sender {

}
@end
