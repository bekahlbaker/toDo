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
@property (weak, nonatomic) IBOutlet UILabel *toDoLbl;
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
    NSLog(@"#3 UPDATING UI");
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

}
@end
