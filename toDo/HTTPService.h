//
//  HTTPService.h
//  toDo
//
//  Created by Rebekah Baker on 3/10/17.
//  Copyright © 2017 Rebekah Baker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ToDoCell.h"

typedef void (^onComplete)(NSArray * _Nullable dataArray, NSString * _Nullable errMessage);
typedef void (^onCompleteSingle)(NSDictionary * _Nullable dict, NSString * _Nullable errMessage);

@interface HTTPService : NSObject

+ (id _Nonnull) instance;
- (void) getToDoItems: (nullable onComplete)completionHandler;
- (void) getSingleItem:(NSInteger)itemID :(nullable onCompleteSingle)completionHandler;
- (void) postNewToDoItem:(NSString* _Nonnull )newItem completionHandler:(nullable onComplete)completionHandler;
- (void) checkItemDone:( NSInteger)itemID completionHandler:(nullable onComplete)completionHandler;
- (void) checkItemNotDone:(NSInteger)itemID completionHandler:(nullable onComplete)completionHandler;
- (void) editItemDescription:(NSString*)newDescription :(NSInteger)itemID completionHandler:(nullable onComplete)completionHandler;
- (void) deleteItem:(NSInteger)itemID completionHandler:(nullable onComplete)completionHandler;
@end
