//
//  SHUImagePicker.m
//  Pods
//
//  Created by Sergey Shulga on 4/28/14.
//
//

#import "SHUImagePicker.h"
#import "SHUCropImageController.h"

@interface SHUImagePicker () <UIImagePickerControllerDelegate, UINavigationControllerDelegate> {

@private
    CGSize                             _cropSize;
    UIImagePickerControllerSourceType  _sourceType;
    UIViewController                  *_targetViewController;
    UIImagePickerController           *_imagePickerController;
    UIImage                           *_imageToCrop;
}

@property (copy, nonatomic)   void(^callbackBlock)(UIImage *cropedImage);

@end

@implementation SHUImagePicker

- (instancetype) initWithTargetViewController:(UIViewController *)targetViewController cropSize:(CGSize )cropSize{
    
    self = [super init];
    
    if (self) {
        _targetViewController = targetViewController;
        _cropSize = cropSize;
        _imagePickerController = [[UIImagePickerController alloc] init];
        _imagePickerController.delegate = self;
    }
    
    return self;
}

- (void) showPickerForSourceType:(UIImagePickerControllerSourceType )sourceType WithCallback:(void (^)(UIImage *))callback{
    self.callbackBlock = callback;
    _sourceType = sourceType;
    _imagePickerController.sourceType = _sourceType;
    [_targetViewController presentViewController:_imagePickerController animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    _imageToCrop = info[UIImagePickerControllerOriginalImage];
    SHUCropImageController *cropViewController = [[SHUCropImageController alloc] initWithNibName:nil bundle:nil imageToCrop:_imageToCrop cropSize:CGSizeMake(250, 100)];
    [picker pushViewController:cropViewController animated:YES];
}

@end
