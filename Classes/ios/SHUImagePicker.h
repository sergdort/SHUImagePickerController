//
//  SHUImagePicker.h
//  Pods
//
//  Created by Sergey Shulga on 4/28/14.
//
//

#import <Foundation/Foundation.h>

@interface SHUImagePicker : NSObject

- (instancetype) initWithTargetViewController:(UIViewController *)targetViewController;

- (void) showPickerForSourceType:(UIImagePickerControllerSourceType )sourceType cropSize:(CGSize)cropSize withCallback:(void (^)(UIImage *))callback;

@end
