//
//  SHUImagePicker.h
//  Pods
//
//  Created by Sergey Shulga on 4/28/14.
//
//

#import <UIKit/UIKit.h>

@interface SHUImagePicker : NSObject

- (void) showPickerInViewController:(UIViewController *)viewController
                      forSourceType:(UIImagePickerControllerSourceType )sourceType
                           cropSize:(CGSize)cropSize
                           fromRect:(CGRect)rect
                       withCallback:(void (^)(UIImage *))callback;

- (void) showPickerInViewController:(UIViewController *)viewController
                      forSourceType:(UIImagePickerControllerSourceType )sourceType
                           cropSize:(CGSize)cropSize
                           fromView:(UIView *)view
                       withCallback:(void (^)(UIImage *))callback;

- (void) showPickerInViewController:(UIViewController *)viewController
                      forSourceType:(UIImagePickerControllerSourceType )sourceType
                           cropSize:(CGSize)cropSize
                      barButtonItem:(UIBarButtonItem *)barButtonItem
                       withCallback:(void (^)(UIImage *))callback;

@end
