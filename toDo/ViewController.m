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
#import "Security/Security.h"
#import "Lockbox/Lockbox.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (nonatomic, strong) NSArray *toDoList;
@property (nonatomic, strong) NSMutableArray *tempArray;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activitySpinner;
- (IBAction)addBtnTapped:(id)sender;

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
    
    self.addBtn.alpha = 0;
    
    [self anonymouslyCreateUserAndLogin];
}


- (void) anonymouslyCreateUserAndLogin {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([Lockbox unarchiveObjectForKey:@"uuid"] != nil) {
            [[HTTPService instance]loginUser:[Lockbox unarchiveObjectForKey:@"uuid"] :^(NSArray * _Nullable dataArray, NSString * _Nullable errMessage) {
                NSLog(@"RETURNING USER HAS BEEN LOGGED IN: %@",[Lockbox unarchiveObjectForKey:@"uuid"]);
                [self downloadData];
            }];
        } else {
            NSString * uuid = [[NSUUID UUID] UUIDString];
            [Lockbox archiveObject:uuid forKey:@"uuid"];
            
            [[HTTPService instance]signUpUser:[Lockbox unarchiveObjectForKey:@"uuid"] :^(NSArray * _Nullable dataArray, NSString * _Nullable errMessage) {
                NSLog(@"NEW USER HAS BEEN CREATED: %@",[Lockbox unarchiveObjectForKey:@"uuid"]);
                [[HTTPService instance]loginUser:[Lockbox unarchiveObjectForKey:@"uuid"] :^(NSArray * _Nullable dataArray, NSString * _Nullable errMessage) {
                    NSLog(@"NEW USER HAS BEEN LOGGED IN: %@",[Lockbox unarchiveObjectForKey:@"uuid"]);
                    [self downloadData];
                }];
            }];
        }
    });
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    [self.activitySpinner startAnimating];
}

-(void) downloadData {
    [[HTTPService instance]getToDoItems:^(NSArray * _Nullable dataArray, NSString * _Nullable errMessage) {
        if (dataArray) {
            NSLog(@"DATA : %@", dataArray);
            self.tempArray = [[NSMutableArray alloc]init];
            
            
            for (NSDictionary *d in dataArray) {
                ToDoItem *item = [[ToDoItem alloc]init];
                item.completed = [[d objectForKey:@"completed"] boolValue];
                item.toDoListItem = [d objectForKey:@"description"];
                item.itemID = [[d objectForKey: @"id"] integerValue];
                
                [self.tempArray insertObject:item atIndex:0];
                
            }
            
            self.toDoList = self.tempArray;
            
            [self updateTableData];
            
        } else if (errMessage) {
            //Display alert
        }
    }];
}

-(void) updateTableData {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activitySpinner stopAnimating];
        [self.tableView reloadData];
    });
}

-(void)checkBtnTouched:(UIButton*)sender {
    NSLog(@"Btn touched! %ld", (long)sender.tag);
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    ToDoCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.completed == 0) {
        
        [[HTTPService instance]checkItemDone:(cell.itemID) completionHandler:^(NSArray * _Nullable dataArray, NSString * _Nullable errMessage) {
            NSLog(@"#1 Completed item!");
            [self downloadDataSingleItem:cell.itemID :sender.tag];
            
        }];
    } else {
        
        [[HTTPService instance]checkItemNotDone:(cell.itemID) completionHandler:^(NSArray * _Nullable dataArray, NSString * _Nullable errMessage) {
            NSLog(@"#1 Have not completed item!");
            [self downloadDataSingleItem:cell.itemID :sender.tag];
            
        }];
    }
}

-(void) downloadDataSingleItem:(NSInteger)itemID :(NSInteger)sender {
    [[HTTPService instance]getSingleItem:itemID :^(NSDictionary * _Nullable dict, NSString * _Nullable errMessage) {
        if (dict) {
            self.tempArray = [[NSMutableArray alloc]init];
            
            NSLog(@"#2 DICTIONARY: %@", dict);
            ToDoItem *item = [[ToDoItem alloc]init];
            item.completed = [[dict objectForKey:@"completed"] boolValue];
            item.toDoListItem = [dict objectForKey:@"description"];
            item.itemID = [[dict objectForKey: @"id"] integerValue];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender inSection:0];
                ToDoCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                
                [cell updateUI:item];
                
            });
            
        } else if (errMessage) {
            
        }
    }];
}

-(void)reloadRows:(NSInteger)index  {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    ToDoCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    ToDoItem *item = [self.tempArray objectAtIndex:index];
    [cell updateUI:item];
}

-(ToDoCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ToDoCell *cell = (ToDoCell*)[tableView dequeueReusableCellWithIdentifier:@"toDo" forIndexPath:indexPath];
    if (!cell) {
        cell = [[ToDoCell alloc]init];
    }
    ToDoItem *item = [self.toDoList objectAtIndex:indexPath.row];
    [cell updateUI:item];
    cell.checkBtn.tag = indexPath.row;
    [cell.checkBtn addTarget:self action:@selector(checkBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.toDoList.count;
}

//EDIT and DELETE
-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    ToDoItem *item = [self.toDoList objectAtIndex:indexPath.row];
    ToDoCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    UITableViewRowAction *button = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                    {
                                        UIAlertController * alert = [UIAlertController
                                                                     alertControllerWithTitle:@"Are you sure you want to delete this item?"
                                                                     message:@"You will not be able to get this back if you delete it."
                                                                     preferredStyle:UIAlertControllerStyleAlert];
                                        
                                        
                                        UIAlertAction* yesButton = [UIAlertAction
                                                                    actionWithTitle:@"Delete"
                                                                    style:UIAlertActionStyleDestructive
                                                                    handler:^(UIAlertAction * action) {
                                                                        
                                                                        [[HTTPService instance]deleteItem:item.itemID completionHandler:^(NSArray * _Nullable dataArray, NSString * _Nullable errMessage) {
                                                                            NSLog(@"Successfully deleted item!");
                                                                            [self downloadData];
                                                                        }];
                                                                    }];
                                        
                                        UIAlertAction* noButton = [UIAlertAction
                                                                   actionWithTitle:@"Cancel"
                                                                   style:UIAlertActionStyleCancel
                                                                   handler:^(UIAlertAction * action) {
                                                                       
                                                                   }];
                                        
                                        [alert addAction:yesButton];
                                        [alert addAction:noButton];
                                        
                                        [self presentViewController:alert animated:YES completion:nil];
                                    }];
    button.backgroundColor = [UIColor colorWithRed:0.91 green:0.42 blue:0.42 alpha:1.0];
    UITableViewRowAction *button2 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Edit" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                     {
                                         NSString *string = cell.toDoLbl.text;
                                         
                                         UIAlertController *alert= [UIAlertController
                                                                    alertControllerWithTitle:@"Edit your to-do description."
                                                                    message: nil
                                                                    preferredStyle:UIAlertControllerStyleAlert];
                                         
                                         UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                                    handler:^(UIAlertAction * action){
                                                                                        UITextField *textField = alert.textFields[0];

                                                                                        [[HTTPService instance]editItemDescription:textField.text :item.itemID completionHandler:^(NSArray * _Nullable dataArray, NSString * _Nullable errMessage) {
                                                                                            NSLog(@"Successfully edited item!");
                                                                                            [self downloadDataSingleItem:item.itemID :indexPath.row];
                                                                                        }];
                                                                                        
                                                                                        
                                                                                    }];
                                         UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive
                                                                                        handler:^(UIAlertAction * action) {
                                                                                            
                                                                                            NSLog(@"cancel btn");
                                                                                            
                                                                                            [alert dismissViewControllerAnimated:YES completion:nil];
                                                                                            
                                                                                        }];
                                         
                                         [alert addAction:ok];
                                         [alert addAction:cancel];
                                         
                                         [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                                             textField.text = string;
                                             textField.keyboardType = UIKeyboardTypeDefault;
                                             textField.autocorrectionType = UITextAutocorrectionTypeYes;
                                         }];
                                         
                                         [self presentViewController:alert animated:YES completion:nil];
                                         
                                         [tableView setEditing:NO animated:YES];
                                         
                                     }];
    
    button2.backgroundColor = [UIColor colorWithRed:0.69 green:0.85 blue:0.80 alpha:1.0];
    UITableViewRowAction *button3 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Share" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                     {
                                         NSLog(@"Action to perform with Button3!");
                                         
                                         NSString *string = cell.toDoLbl.text;
                                         NSArray *items = @[@"To Do:", string];
                                         
                                         UIActivityViewController *controller = [[UIActivityViewController alloc]initWithActivityItems:items applicationActivities:nil];
                                         
                                         [self presentViewController:controller animated:YES completion:^{
                                             NSLog(@"HAS BEEN SHARED");
                                         }];
                                     }];
    button3.backgroundColor = [UIColor colorWithRed:0.69 green:0.58 blue:0.43 alpha:1.0];
    
    return @[button, button2, button3];
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (![self.textField.text isEqualToString:@""]) {
        [self uploadData];
    }
    [self updateTextField];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch * touch = [touches anyObject];
    if(touch.phase == UITouchPhaseBegan) {
        [self updateTextField];
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    self.textField.text = @"";
    self.addBtn.alpha = 1;
    [self.addBtn setImage:[UIImage imageNamed:@"Add"] forState:UIControlStateNormal];
}


- (void) updateTextField {
    [_textField resignFirstResponder];
    self.textField.text = @"Add a to-do item...";
    self.addBtn.alpha = 0;
}


- (void) uploadData {
    [[HTTPService instance]postNewToDoItem:self.textField.text completionHandler:^(NSArray * _Nullable dataArray, NSString * _Nullable errMessage) {
        [self downloadData];
    }];
}

- (IBAction)addBtnTapped:(id)sender {
    if ([self.textField hasText]) {
        [self uploadData];
    }
    [self updateTextField];
}

@end
