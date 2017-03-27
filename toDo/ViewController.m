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
@property (nonatomic, strong) NSArray *todoCompletedList;
@property (nonatomic, strong) NSMutableArray *tempArray;
@property (nonatomic, strong) NSMutableArray *tempCompletedArray;
@property BOOL completedIsHidden;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
- (IBAction)addBtnTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *showCompletedBtn;
- (IBAction)showCompletedBtnTapped:(id)sender;
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
    self.todoCompletedList = [[NSArray alloc]init];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressGestureRecognized:)];
    [self.tableView addGestureRecognizer:longPress];
    
    
    self.completedIsHidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
    [self downloadData];
}

-(void) downloadData {
    [[HTTPService instance]getToDoItems:^(NSArray * _Nullable dataArray, NSString * _Nullable errMessage) {
        if (dataArray) {
            self.tempArray = [[NSMutableArray alloc]init];
            self.tempCompletedArray = [[NSMutableArray alloc]init];
            
            for (NSDictionary *d in dataArray) {
                ToDoItem *item = [[ToDoItem alloc]init];
                item.completed = [[d objectForKey:@"completed"] boolValue];
                item.toDoListItem = [d objectForKey:@"description"];
                item.itemID = [[d objectForKey: @"id"] integerValue];
                if (item.completed == 0) {
                 [self.tempArray insertObject:item atIndex:0];
                } else {
                    [self.tempCompletedArray addObject:item];
                }
            }

            if (self.completedIsHidden == YES) {
                self.toDoList = self.tempArray;
            } else if (self.completedIsHidden == NO) {
                NSArray *newArray = [self.tempArray arrayByAddingObjectsFromArray:self.tempCompletedArray];
                self.toDoList = newArray;
            }
            
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

-(void)checkBtnTouched:(UIButton*)sender :(NSNotification*)notification {
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
            self.tempCompletedArray = [[NSMutableArray alloc]init];
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
            //Display alert
        }
    }];
}

-(void)reloadRows:(NSInteger)index  {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        ToDoCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        if (self.completedIsHidden == YES) {
            ToDoItem *item = [self.tempArray objectAtIndex:index];
            [cell updateUI:item];
        } else if (self.completedIsHidden == NO) {
            NSMutableArray *newArray = [[self.tempArray arrayByAddingObjectsFromArray:self.tempCompletedArray] mutableCopy];
            ToDoItem *item = [newArray objectAtIndex:index];
            [cell updateUI:item];
        }
}

-(ToDoCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ToDoCell *cell = (ToDoCell*)[tableView dequeueReusableCellWithIdentifier:@"toDo" forIndexPath:indexPath];
    if (!cell) {
        cell = [[ToDoCell alloc]init];
    }
    ToDoItem *item = [self.toDoList objectAtIndex:indexPath.row];
    [cell updateUI:item];
    cell.checkBtn.tag = indexPath.row;
    [cell.checkBtn addTarget:self action:@selector(checkBtnTouched::) forControlEvents:UIControlEventTouchUpInside];

    return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.toDoList.count;
}

//EDIT and DELETE
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    ToDoItem *item = [self.toDoList objectAtIndex:indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"Are you sure you want to delete this item?"
                                     message:@"You will not be able to get this back if you delete it."
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        
        
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"Delete"
                                    style:UIAlertActionStyleDestructive
                                    handler:^(UIAlertAction * action) {
                                        //Handle your yes please button action here
                                        [[HTTPService instance]deleteItem:item.itemID completionHandler:^(NSArray * _Nullable dataArray, NSString * _Nullable errMessage) {
                                            NSLog(@"Successfully deleted item!");
                                            [self downloadData];
                                        }];
                                    }];
        
        UIAlertAction* noButton = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction * action) {
                                       //Handle no, thanks button
                                   }];
        
        [alert addAction:yesButton];
        [alert addAction:noButton];
        
        [self presentViewController:alert animated:YES completion:nil];
    
    } else {
        NSLog(@"Unhandled editing style! %ld", (long)editingStyle);
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self updateTextField];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    self.textField.text = @"";
    self.addBtn.alpha = 1;
    [self.addBtn setImage:[UIImage imageNamed:@"Add-shadow"] forState:UIControlStateNormal];
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

- (IBAction)longPressGestureRecognized:(id)sender {
    
    UILongPressGestureRecognizer *longPress = (UILongPressGestureRecognizer *)sender;
    UIGestureRecognizerState state = longPress.state;
    
    CGPoint location = [longPress locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    
    // More coming soon...
    static UIView       *snapshot = nil;        ///< A snapshot of the row user is moving.
    static NSIndexPath  *sourceIndexPath = nil; ///< Initial index path, where gesture begins.
    
    switch (state) {
        case UIGestureRecognizerStateBegan: {
            [self.showCompletedBtn setTitle:@"Drag to Reorder" forState:UIControlStateNormal];
            if (indexPath) {
                sourceIndexPath = indexPath;
                
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                
                // Take a snapshot of the selected row using helper method.
                snapshot = [self customSnapshotFromView:cell];
                
                // Add the snapshot as subview, centered at cell's center...
                __block CGPoint center = cell.center;
                snapshot.center = center;
                snapshot.alpha = 0.0;
                [self.tableView addSubview:snapshot];
                [UIView animateWithDuration:0.25 animations:^{
                    
                    // Offset for gesture location.
                    center.y = location.y;
                    snapshot.center = center;
                    snapshot.transform = CGAffineTransformMakeScale(1.05, 1.05);
                    snapshot.alpha = 0.98;
                    
                    // Fade out.
                    cell.alpha = 0.0;
                    
                } completion:^(BOOL finished) {
                    
                    cell.hidden = YES;
                    
                }];
            }
            break;
        }
            // More coming soon...
        case UIGestureRecognizerStateChanged: {
             [self.showCompletedBtn setTitle:@"Drag to Reorder" forState:UIControlStateNormal];
            CGPoint center = snapshot.center;
            center.y = location.y;
            snapshot.center = center;
            
            // Is destination valid and is it different from source?
            if (indexPath && ![indexPath isEqual:sourceIndexPath]) {
                
                // ... update data source.
                if (self.completedIsHidden == YES) {
                    [self.tempArray exchangeObjectAtIndex:indexPath.row withObjectAtIndex:sourceIndexPath.row];
                } else if (self.completedIsHidden == NO) {
                    NSMutableArray *newArray = [[self.tempArray arrayByAddingObjectsFromArray:self.tempCompletedArray] mutableCopy];
                    [newArray exchangeObjectAtIndex:indexPath.row withObjectAtIndex:sourceIndexPath.row];
                }
                
                // ... move the rows.
                [self.tableView moveRowAtIndexPath:sourceIndexPath toIndexPath:indexPath];
                
                // ... and update source so it is in sync with UI changes.
                sourceIndexPath = indexPath;
            }
            break;
        }
            // More coming soon...
        default: {
            // Clean up.
            
            if (self.completedIsHidden == YES) {
                [self.showCompletedBtn setTitle:@"Show Completed" forState:UIControlStateNormal];
            } else if (self.completedIsHidden == NO) {
                [self.showCompletedBtn setTitle:@"Hide Completed" forState:UIControlStateNormal];
            }
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:sourceIndexPath];
            cell.hidden = NO;
            cell.alpha = 0.0;
            [UIView animateWithDuration:0.25 animations:^{
                
                snapshot.center = cell.center;
                snapshot.transform = CGAffineTransformIdentity;
                snapshot.alpha = 0.0;
                
                // Undo fade out.
                cell.alpha = 1.0;
                
            } completion:^(BOOL finished) {
                
                sourceIndexPath = nil;
                [snapshot removeFromSuperview];
                snapshot = nil;
                
            }];
            break;
        }
    }
}

// Add this at the end of your .m file. It returns a customized snapshot of a given view.
- (UIView *)customSnapshotFromView:(UIView *)inputView {
    
    // Make an image from the input view.
    UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, NO, 0);
    [inputView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Create an image view.
    UIView *snapshot = [[UIImageView alloc] initWithImage:image];
    snapshot.layer.masksToBounds = NO;
    snapshot.layer.cornerRadius = 0.0;
    snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
    snapshot.layer.shadowRadius = 5.0;
    snapshot.layer.shadowOpacity = 0.4;
    
    return snapshot;
}

- (IBAction)addBtnTapped:(id)sender {
    if (![self.textField.text isEqualToString:@""]) {
        [self uploadData];
    }
    [self updateTextField];
}
- (IBAction)showCompletedBtnTapped:(id)sender {
    if (self.completedIsHidden == YES) {
        self.completedIsHidden = NO;
        [self downloadData];
        [self.showCompletedBtn setTitle:@"Hide Completed" forState:UIControlStateNormal];
    } else if (self.completedIsHidden == NO) {
        self.completedIsHidden = YES;
        [self downloadData];
        [self.showCompletedBtn setTitle:@"Show Completed" forState:UIControlStateNormal];
    }
}
@end
