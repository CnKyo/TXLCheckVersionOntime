//
//  ViewController.m
//  TXLCheckVersionOntime
//
//  Created by cocomanber on 2017/7/28.
//  Copyright © 2017年 cocomanber. All rights reserved.
//

#import "ViewController.h"
#import "TXLCheckVersionManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [TXLCheckVersionManager  checkNewEditionWithAppID:@"1177904945" withCheckType:UpdateTypeDay ctrl:self];
    
    [TXLCheckVersionManager checkNewEditionWithAppID:@"1177904945" withCheckType:UpdateTypeDay CustomAlert:^(TXLAppStoreModel *appInfo) {
        
    }];//2种用法,自定义Alert
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
