//
//  NetworkController.h
//  HeyYou
//
//  Created by William Richman on 11/17/14.
//  Copyright (c) 2014 Hey You!. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Dot.h"
#import "ErrorsHandler.h"
#import "Message.h"

@interface NetworkController : NSObject <NSURLSessionDelegate, NSURLSessionTaskDelegate>

@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSString *username;

+ (id)sharedController;

- (void)fetchDotsWithRegion: (MKCoordinateRegion) region completionHandler: (void (^)(NSError *error, NSArray *dots))completionHandler;

- (void)fetchTokenWithUsername: (NSString *)username password:(NSString*)password completionHandler: (void (^)(NSError *error, bool success))completionHandler;

- (void)postDot: (Dot*)dot completionHandler: (void (^)(NSError *error, bool success))completionHandler;

- (void)createUserWithUsername: (NSString*)username password:(NSString*)password birthday:(NSDate*)birthday email:(NSString*)email completionHandler:(void (^)(NSError *error, bool success))completionHandler;

- (void)postComment: (NSString *) comment forDot:(Dot*)dot completionHandler: (void (^)(NSError *error, bool success))completionHandler;

- (void)getDotByID: (NSString *)dotID completionHandler: (void (^)(NSError * error, Dot * dot))completionHandler;

- (void)postToggleStarOnDot: (Dot*)dot completionHandler:(void (^)(NSError *error, bool success))completionHandler;

- (void)getAllMyDotsWithCompletionHandler: (void (^)(NSError *error, NSArray * dots))completionHandler;

- (void)postMessage: (NSString *)text toUser: (NSString *)username withCompletionHandler: (void (^)(NSError *error, bool success))completionHandler;

- (void)getAllChatPartnersWithCompletionHandler: (void (^)(NSError *error, NSArray * messages))completionHandler;

- (void)getMessagesFromUser:(NSString *)username withCompletionHandler: (void (^)(NSError *error, NSArray * messages))completionHandler;

- (void)flagDot: (Dot*)dot completionHandler:(void (^)(NSError *error, bool success))completionHandler;

- (void)flagComment: (Comment*)comment completionHandler:(void (^)(NSError *error, bool success))completionHandler;

@end
