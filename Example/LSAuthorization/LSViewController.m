//
//  LSViewController.m
//  LSDeviceUIModule
//
//  Created by malai on 02/26/2020.
//  Copyright (c) 2020 malai. All rights reserved.
//

#import "LSViewController.h"
#import "LSAuthorization.h"
@interface LSViewController ()

@end

@implementation LSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
//    NSLog(@"%@", str);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
        case 0:
            lsw_authorize_device(@"", @"", @"", @"",  ^(LSAccessCode code) {
                NSLog(@"请求结果，%d", (int)code);
            });
            break;
            
        case 1:
//            [LSModuleManager openURL:LSDeviceServiceShowAddNewDevice];
            break;
            
        default:
//            [LSModule(LSReportService) uploadToSerer];
            
//            [LSModule(LSUserService) logoutWithCompletion:^(NSInteger code, NSString * _Nonnull msg) {
//
//            }];
            break;
    }
    
    
}



@end
