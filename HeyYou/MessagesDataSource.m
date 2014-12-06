//
//  MessagesDataSource.m
//  HeyYou
//
//  Created by Cameron Klein on 12/5/14.
//  Copyright (c) 2014 Hey You!. All rights reserved.
//

#import "MessagesDataSource.h"

@interface MessagesDataSource()

@property (nonatomic, strong) NSDictionary *messages;

@end

@implementation MessagesDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  return [UITableViewCell new];
}

@end
