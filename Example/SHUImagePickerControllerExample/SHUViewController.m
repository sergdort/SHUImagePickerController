//
//  SHUViewController.m
//  SHUImagePickerControllerExample
//
//  Created by Sergey Shulga on 4/27/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "SHUViewController.h"
#import <SHUImagePickerController/SHUImagePicker.h>

@interface SHUViewController ()

@property (strong, nonatomic) SHUImagePicker *imagePicker;

@end

@implementation SHUViewController


- (IBAction)buttonPressed:(id)sender {
    self.imagePicker = [[SHUImagePicker alloc] initWithTargetViewController:self cropSize:CGSizeZero];
    [self.imagePicker showPickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary WithCallback:nil];
}

@end
