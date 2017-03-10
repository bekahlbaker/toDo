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
@property (weak, nonatomic) IBOutlet UIButton *editDoneBtn;
- (IBAction)editDoneBtnTapped:(id)sender;
@property (nonatomic, strong) NSArray *toDoList;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 45;
    
    self.textField.delegate = self;
    self.textField.returnKeyType = UIReturnKeyDone;
    
    self.toDoList = [[NSArray alloc]init];
    
    [self downloadData];
}

-(void) downloadData {
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
    [self updateTextField];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    self.textField.text = @"";
    [self.editDoneBtn setTitle:@"Done" forState:UIControlStateNormal];
}

- (IBAction)editDoneBtnTapped:(id)sender {
    if ([[self.editDoneBtn titleForState:UIControlStateNormal] isEqualToString:@"Done"]) {
        if (![self.textField.text isEqualToString:@""]) {
            [self uploadData];
        }
    }
    [self updateTextField];
}

- (void) updateTextField {
    [_textField resignFirstResponder];
    [self.editDoneBtn setTitle:@"Edit" forState:UIControlStateNormal];
    self.textField.text = @"Add a to-do item...";
}

- (void) uploadData {
    [[HTTPService instance]postNewToDoItem:self.textField.text completionHandler:^(NSArray * _Nullable dataArray, NSString * _Nullable errMessage) {
        [self downloadData];
    }];
}

@end
