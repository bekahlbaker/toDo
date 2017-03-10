//
//  ToDoCell.m
//  toDo
//
//  Created by Rebekah Baker on 3/9/17.
//  Copyright © 2017 Rebekah Baker. All rights reserved.
//

#import "ToDoCell.h"
#import "ToDoItem.h"

@interface ToDoCell()
@property (weak, nonatomic) IBOutlet UILabel *toDoLbl;

@end

@implementation ToDoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)updateUI:(nonnull ToDoItem*)toDoItem {
    self.toDoLbl.text = toDoItem.toDoListItem;
}

@end
