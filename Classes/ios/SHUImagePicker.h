//
//  SHUImagePicker.h
//  Pods
//
//  Created by Sergey Shulga on 4/28/14.
//
//

#import <Foundation/Foundation.h>

@interface SHUImagePicker : NSObject

- (void) showPickerInViewController:(UIViewController *)viewController forSourceType:(UIImagePickerControllerSourceType )sourceType cropSize:(CGSize)cropSize fromRect:(CGRect)rect withCallback:(void (^)(UIImage *))callback;

@end
