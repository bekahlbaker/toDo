//
//  HTTPService.m
//  toDo
//
//  Created by Rebekah Baker on 3/10/17.
//  Copyright © 2017 Rebekah Baker. All rights reserved.
//

#import "HTTPService.h"

#define URL_BASE "https://bekah-todo-api.herokuapp.com"
#define URL_ITEMS "/todos"
#define URL_USERS "/users"
#define URL_USERS_LOGIN "/users/login"
#define URL_ID "/"

@implementation HTTPService

+ (id) instance {
    static HTTPService *sharedInstance = nil;
    
    @synchronized (self) {
        if (sharedInstance == nil)
            sharedInstance = [[self alloc]init];
    }
    return sharedInstance;
}

- (void) signUpUser:(NSString*)uuid :(nullable onComplete)completionHandler {
    NSDictionary *item = @{@"uuid": uuid};
    NSError *error;
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"%s%s", URL_BASE, URL_USERS]];
    NSURLSession *session = [NSURLSession sharedSession];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    [request setHTTPMethod:@"POST"];
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:item options:0 error:&error];
    
    [request setHTTPBody:postData];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data != nil) {
            NSError *err;
            NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
            
            if (err == nil) {
                completionHandler(json, nil);
            } else {
                completionHandler(nil, @"Data is corrupt. Try again");
            }
        } else {
            NSLog(@"NetowrkErr: %@", error.debugDescription);
            completionHandler(nil, @"Problem connecting to server");
        }
    }];
    
    [postDataTask resume];
}

- (void) loginUser:(NSString*)uuid :(nullable onComplete)completionHandler {
    NSDictionary *item = @{@"uuid": uuid};
    NSError *error;
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"%s%s", URL_BASE, URL_USERS_LOGIN]];
    NSURLSession *session = [NSURLSession sharedSession];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    [request setHTTPMethod:@"POST"];

    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:item options:0 error:&error];
    
    [request setHTTPBody:postData];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data != nil) {
            NSURLResponse* responseFrom = response;
            NSDictionary* headers = [(NSHTTPURLResponse *)responseFrom allHeaderFields];
            NSString *authToken = [headers objectForKey:@"Auth"];
            NSLog(@"AUTH TOKEN: %@", authToken);
            [[NSUserDefaults standardUserDefaults] setObject:authToken forKey:@"token"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            NSError *err;
            NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
            
            if (err == nil) {
                completionHandler(json, nil);
                
            } else {
                completionHandler(nil, @"Data is corrupt. Try again");
            }
        } else {
            NSLog(@"NetowrkErr: %@", error.debugDescription);
            completionHandler(nil, @"Problem connecting to server");
        }
    }];
    
    [postDataTask resume];
}

- (void) getToDoItems:(nullable onComplete)completionHandler {
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"%s%s", URL_BASE, URL_ITEMS]];
    NSURLSession *session = [NSURLSession sharedSession];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"token"] forHTTPHeaderField:@"Auth"];
    [request setHTTPMethod:@"GET"];
    
    [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (data != nil) {
            NSError *err;
            NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
            
            if (err == nil) {
                completionHandler(json, nil);
                NSLog(@"COMPLETED GETTING TODOS: %@", json);
            } else {
                completionHandler(nil, @"Data is corrupt. Try again");
            }
        } else {
            NSLog(@"NetowrkErr: %@", error.debugDescription);
            completionHandler(nil, @"Problem connecting to server");
        }
        
    }] resume];
}

- (void) getSingleItem:(NSInteger)itemID :(nullable onCompleteSingle)completionHandler {
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"%s%s%s%ld", URL_BASE, URL_ITEMS, URL_ID, (long)itemID]];
    NSURLSession *session = [NSURLSession sharedSession];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"token"] forHTTPHeaderField:@"Auth"];
    [request setHTTPMethod:@"GET"];
    
    [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data != nil) {
            NSError *err;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
            
            if (err == nil) {
                completionHandler(json, nil);
            } else {
                completionHandler(nil, @"Data is corrupt. Try again");
            }
        } else {
            NSLog(@"NetowrkErr: %@", error.debugDescription);
            completionHandler(nil, @"Problem connecting to server");
        }
        
    }] resume];
}


- (void) postNewToDoItem:(NSString*)newItem completionHandler:(nullable onComplete)completionHandler {
    NSDictionary *item = @{@"description": newItem};
    NSError *error;
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"%s%s", URL_BASE, URL_ITEMS]];
    NSURLSession *session = [NSURLSession sharedSession];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"token"] forHTTPHeaderField:@"Auth"];
    
    [request setHTTPMethod:@"POST"];
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:item options:0 error:&error];
    
    [request setHTTPBody:postData];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data != nil) {
            NSError *err;
            NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
            
            if (err == nil) {
                completionHandler(json, nil);
            } else {
                completionHandler(nil, @"Data is corrupt. Try again");
            }
        } else {
            NSLog(@"NetowrkErr: %@", error.debugDescription);
            completionHandler(nil, @"Problem connecting to server");
        }
    }];
    
    [postDataTask resume];
}

- (void) checkItemDone:(NSInteger)itemID completionHandler:(nullable onComplete)completionHandler {

    NSDictionary *item = @{@"completed": @true};
    NSError *error;
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"%s%s%s%ld", URL_BASE, URL_ITEMS, URL_ID, (long)itemID]];
    NSURLSession *session = [NSURLSession sharedSession];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"token"] forHTTPHeaderField:@"Auth"];
    
    [request setHTTPMethod:@"PUT"];
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:item options:0 error:&error];
    
    [request setHTTPBody:postData];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data != nil) {
            NSError *err;
            NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
            
            if (err == nil) {
                completionHandler(json, nil);
            } else {
                completionHandler(nil, @"Data is corrupt. Try again");
            }
        } else {
            NSLog(@"NetowrkErr: %@", error.debugDescription);
            completionHandler(nil, @"Problem connecting to server");
        }
    }];
    
    [postDataTask resume];
}

- (void) checkItemNotDone:(NSInteger)itemID completionHandler:(nullable onComplete)completionHandler {
    NSDictionary *item = @{@"completed": @false};
    NSError *error;
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"%s%s%s%ld", URL_BASE, URL_ITEMS, URL_ID, (long)itemID]];
    NSLog(@"%@", url);
    NSURLSession *session = [NSURLSession sharedSession];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"token"] forHTTPHeaderField:@"Auth"];
    
    [request setHTTPMethod:@"PUT"];
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:item options:0 error:&error];
    
    [request setHTTPBody:postData];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data != nil) {
            NSError *err;
            NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
            
            if (err == nil) {
                completionHandler(json, nil);
            } else {
                completionHandler(nil, @"Data is corrupt. Try again");
            }
        } else {
            NSLog(@"NetowrkErr: %@", error.debugDescription);
            completionHandler(nil, @"Problem connecting to server");
        }
    }];
    
    [postDataTask resume];
}

- (void) editItemDescription:(NSString*)newDescription :(NSInteger)itemID completionHandler:(nullable onComplete)completionHandler {
    NSDictionary *item = @{@"description": newDescription};
    NSError *error;
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"%s%s%s%ld", URL_BASE, URL_ITEMS, URL_ID, (long)itemID]];
    NSLog(@"%@", url);
    NSURLSession *session = [NSURLSession sharedSession];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"token"] forHTTPHeaderField:@"Auth"];
    
    [request setHTTPMethod:@"PUT"];
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:item options:0 error:&error];
    
    [request setHTTPBody:postData];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data != nil) {
            NSError *err;
            NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
            
            if (err == nil) {
                completionHandler(json, nil);
            } else {
                completionHandler(nil, @"Data is corrupt. Try again");
            }
        } else {
            NSLog(@"NetowrkErr: %@", error.debugDescription);
            completionHandler(nil, @"Problem connecting to server");
        }
    }];
    
    [postDataTask resume];
}

- (void) deleteItem:(NSInteger)itemID completionHandler:(nullable onComplete)completionHandler {
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"%s%s%s%ld", URL_BASE, URL_ITEMS, URL_ID, (long)itemID]];
    NSLog(@"%@", url);
    NSURLSession *session = [NSURLSession sharedSession];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"token"] forHTTPHeaderField:@"Auth"];
    
    [request setHTTPMethod:@"DELETE"];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data != nil) {
            NSError *err;
            NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
            
            if (err == nil) {
                completionHandler(json, nil);
            } else {
                completionHandler(nil, @"Data is corrupt. Try again");
            }
        } else {
            NSLog(@"NetowrkErr: %@", error.debugDescription);
            completionHandler(nil, @"Problem connecting to server");
        }
    }];
    
    [postDataTask resume];
}


@end

