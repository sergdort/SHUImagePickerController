//
//  SHUImagePicker.h
//  Pods
//
//  Created by Sergey Shulga on 4/28/14.
//
//

#import <Foundation/Foundation.h>

@interface SHUImagePicker : NSObject

- (instancetype) initWithTargetViewController:(UIViewController *)targetViewController cropSize:(CGSize )cropSize;

- (void) showPickerForSourceType:(UIImagePickerControllerSourceType )sourceType WithCallback:(void (^)(UIImage *))callback;

@end
