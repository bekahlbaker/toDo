//
//  ViewController.m
//  toDo
//
//  Created by Rebekah Baker on 3/9/17.
//  Copyright © 2017 Rebekah Baker. All rights reserved.
//

#import "ViewController.h"
#import "ToDoCell.h"
#import "ToDoItem.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (nonatomic, strong) NSArray *toDoList;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.textField.delegate = self;
    
    self.toDoList = [[NSArray alloc]init];
    
    NSMutableArray *tempArray = [NSMutableArray arrayWithObjects:@"Dishes", @"Trash", @"Laundry", nil];
    
    self.toDoList = tempArray;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ToDoCell *cell = (ToDoCell*) [tableView dequeueReusableCellWithIdentifier:@"toDo"];
    cell.textLabel.text = [self.toDoList objectAtIndex:indexPath.row];
    if (!cell) {
        cell = [[ToDoCell alloc]init];
    }

    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(nonnull UITableViewCell *)cell forRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
//    ToDoItem *item = [self.toDoList objectAtIndex:indexPath.row];
//    NSLog(@"ITEM %@", item);
//    ToDoCell *toDoItem = (ToDoCell*)cell;
//    NSLog(@"CELL %@", toDoItem);
//    [toDoItem updateUI:item];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.toDoList.count;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
