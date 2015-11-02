//
//  ViewController.m
//  SHUImagePickerControllerExample
//
//  Created by Segii Shulga on 11/2/15.
//  Copyright © 2015 Sergey Shulga. All rights reserved.
//

#import "ViewController.h"
#import "SHUImagePicker.h"

@interface ViewController ()

@property (strong, nonatomic) SHUImagePicker *imagePicker;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
   [super viewDidLoad];
   self.imagePicker = [SHUImagePicker new];
   // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)buttonPressed:(id)sender {
   __weak ViewController *weakSelf = self;
   [self.imagePicker showPickerInViewController:self
                                  forSourceType:UIImagePickerControllerSourceTypePhotoLibrary cropSize:CGSizeMake(300, 200)
                                     fromView:sender
                                   withCallback:^(UIImage *image) {
                                      ViewController *strongSelf = weakSelf;
                                      strongSelf.imageView.image = image;
                                   }];
}

@end
