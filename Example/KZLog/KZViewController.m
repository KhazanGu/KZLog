//
//  KZViewController.m
//  KZLog
//
//  Created by KhazanGu on 03/15/2021.
//  Copyright (c) 2021 KhazanGu. All rights reserved.
//

#import "KZViewController.h"

@interface KZViewController ()

@end

@implementation KZViewController

- (IBAction)debug:(id)sender {
    
    for (int i = 1000000; i<1050000; i++) {
        NSLog(@"%f", pow(i, 25));
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
