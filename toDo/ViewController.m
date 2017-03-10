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
#import "HTTPService.h"

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
    self.tableView.rowHeight = 45;
    
    self.textField.delegate = self;
    
    self.toDoList = [[NSArray alloc]init];
    
    [[HTTPService instance]getToDoItems:^(NSArray * _Nullable dataArray, NSString * _Nullable errMessage) {
        if (dataArray) {
            
            NSMutableArray *arr = [[NSMutableArray alloc]init];
            
            for (NSDictionary *d in dataArray) {
                ToDoItem *item = [[ToDoItem alloc]init];
                item.toDoListItem = [d objectForKey:@"item"];
                
                [arr addObject:item];
            }
            
            self.toDoList = arr;
            
            [self updateTableData];
            
        } else if (errMessage) {
            //Display alert
        }
    }];
}

-(void) updateTableData {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ToDoCell *cell = (ToDoCell*) [tableView dequeueReusableCellWithIdentifier:@"toDo"];
//    cell.textLabel.text = [self.toDoList objectAtIndex:indexPath.row];
    if (!cell) {
        cell = [[ToDoCell alloc]init];
    }

    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(nonnull UITableViewCell *)cell forRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    ToDoItem *item = [self.toDoList objectAtIndex:indexPath.row];
    ToDoCell *toDoItem = (ToDoCell*)cell;
    [toDoItem updateUI:item];
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
