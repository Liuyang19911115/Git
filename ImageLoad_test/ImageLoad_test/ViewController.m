//
//  ViewController.m
//  ImageLoad_test
//
//  Created by 刘杨 on 15/10/25.
//  Copyright © 2015年 刘杨. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, readwrite, strong) UITableView *tableView;
@property (nonatomic, readwrite, strong) NSMutableArray *array;
@end

NSString *const identifier = @"cell";

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:identifier];
    self.tableView.rowHeight = 80;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    cell.imageView.image = [UIImage imageNamed:@"2"];
    if (self.tableView.dragging == NO && self.tableView.decelerating == NO) {
        [self requestWithURLString:self.array[indexPath.row] cell:cell];
    }
    
    cell.textLabel.text = self.array[indexPath.row];
    cell.textLabel.textColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.7];
    cell.textLabel.font = [UIFont systemFontOfSize:12];
    cell.textLabel.numberOfLines = 0;
    
    return cell;
}

- (void)requestWithURLString:(NSString *)URLString cell:(UITableViewCell *)cell{
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:
                                      [NSURL URLWithString:URLString]
                                            completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
               if (data) [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                   cell.imageView.image = [UIImage imageWithData:data];
               }];
           }];
    [dataTask resume];
}

- (NSMutableArray *)array{
    if (!_array) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"images"
                                                         ofType:@"plist"];
        _array = [NSMutableArray arrayWithContentsOfFile:path];
    }
    return _array;
}



- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self.tableView reloadRowsAtIndexPaths:
                            [self.tableView indexPathsForVisibleRows]
                          withRowAnimation:UITableViewRowAnimationFade];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSLog(@"%@", self.array[indexPath.row]);
        [self.array removeObject:self.array[indexPath.row]];
    }
    [self.tableView reloadData];
    NSLog(@"array count : %ld", self.array.count);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
