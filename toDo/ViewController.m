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
//@property (weak, nonatomic) IBOutlet UIButton *editDoneBtn;
- (IBAction)editDoneBtnTapped:(id)sender;
@property (nonatomic, strong) NSArray *toDoList;
@property (nonatomic, strong) NSArray *todoCompletedList;
@property (nonatomic, strong) NSMutableArray *tempArray;

@property (weak, nonatomic) IBOutlet UIButton *addBtn;
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
    self.todoCompletedList = [[NSArray alloc]init];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressGestureRecognized:)];
    [self.tableView addGestureRecognizer:longPress];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadData:) name:@"downloadData" object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"downloadData" object:self];
}

-(void) downloadData:(NSNotification*)notification {
    [[HTTPService instance]getToDoItems:^(NSArray * _Nullable dataArray, NSString * _Nullable errMessage) {
        if (dataArray) {
//            NSLog(@"%@", dataArray);
            self.tempArray = [[NSMutableArray alloc]init];
            
            for (NSDictionary *d in dataArray) {
                ToDoItem *item = [[ToDoItem alloc]init];
                item.completed = [[d objectForKey:@"completed"] boolValue];
                item.toDoListItem = [d objectForKey:@"description"];
                item.itemID = [[d objectForKey: @"id"] integerValue];
                if (item.completed == 0) {
                 [self.tempArray insertObject:item atIndex:0];
                } else {
                    [self.tempArray addObject:item];
                }
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
    self.addBtn.alpha = 1;
    [self.addBtn setImage:[UIImage imageNamed:@"Add-shadow"] forState:UIControlStateNormal];
//    [self.editDoneBtn setTitle:@"Done" forState:UIControlStateNormal];
}

//- (IBAction)editDoneBtnTapped:(id)sender {
//    if ([[self.editDoneBtn titleForState:UIControlStateNormal] isEqualToString:@"Done"]) {
//        if (![self.textField.text isEqualToString:@""]) {
//            [self uploadData];
//        }
//    } else if ([[self.editDoneBtn titleForState:UIControlStateNormal] isEqualToString:@"Edit"]) {
////        [self.tableView setEditing:YES animated:YES];
//    }
//    [self updateTextField];
//}

- (void) updateTextField {
    [_textField resignFirstResponder];
//    [self.editDoneBtn setTitle:@"Edit" forState:UIControlStateNormal];
    self.textField.text = @"Add a to-do item...";
//    [self.addBtn setImage:[UIImage imageNamed:@"Add-flat"] forState:UIControlStateNormal];
    self.addBtn.alpha = 0;
}

- (void) uploadData {
    [[HTTPService instance]postNewToDoItem:self.textField.text completionHandler:^(NSArray * _Nullable dataArray, NSString * _Nullable errMessage) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"downloadData" object:self];
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
            CGPoint center = snapshot.center;
            center.y = location.y;
            snapshot.center = center;
            
            // Is destination valid and is it different from source?
            if (indexPath && ![indexPath isEqual:sourceIndexPath]) {
                
                // ... update data source.
                [self.tempArray exchangeObjectAtIndex:indexPath.row withObjectAtIndex:sourceIndexPath.row];
                
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
//    if ([[self.editDoneBtn titleForState:UIControlStateNormal] isEqualToString:@"Done"]) {
        if (![self.textField.text isEqualToString:@""]) {
            [self uploadData];
//        }
//    } else if ([[self.editDoneBtn titleForState:UIControlStateNormal] isEqualToString:@"Edit"]) {
        //        [self.tableView setEditing:YES animated:YES];
    }
    [self updateTextField];
}
@end
