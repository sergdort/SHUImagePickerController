//
//  SHUImagePicker.m
//  Pods
//
//  Created by Sergey Shulga on 4/28/14.
//
//

#import "SHUImagePicker.h"
#import "SHUCropImageController.h"

@interface SHUImagePicker () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, SHUCropImageControllerDelegate> {

@private
    CGSize                             _cropSize;
    UIImagePickerControllerSourceType  _sourceType;
    UIViewController                  *_targetViewController;
    UIImagePickerController           *_imagePickerController;
    UIImage                           *_imageToCrop;
}

@property (nonatomic, strong) UIPopoverController *popoverController;

@property (copy, nonatomic)   void(^callbackBlock)(UIImage *cropedImage);

@end

@implementation SHUImagePicker

- (instancetype) initWithTargetViewController:(UIViewController *)targetViewController{
    
    self = [super init];
    
    if (self) {
        _targetViewController = targetViewController;
        _imagePickerController = [[UIImagePickerController alloc] init];
        _imagePickerController.delegate = self;
    }
    
    return self;
}

- (void) showPickerForSourceType:(UIImagePickerControllerSourceType )sourceType cropSize:(CGSize)cropSize fromRect:(CGRect)rect withCallback:(void (^)(UIImage *))callback{
    self.callbackBlock = callback;
    _sourceType = sourceType;
    _cropSize = cropSize;
    _imagePickerController.sourceType = _sourceType;
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.popoverController = [[UIPopoverController alloc] initWithContentViewController:_imagePickerController];
        [self.popoverController presentPopoverFromRect:rect inView:_targetViewController.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }else{
        [_targetViewController presentViewController:_imagePickerController animated:YES completion:nil];
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    _imageToCrop = info[UIImagePickerControllerOriginalImage];
    SHUCropImageController *cropViewController = [[SHUCropImageController alloc] initWithNibName:nil bundle:nil imageToCrop:_imageToCrop cropSize:_cropSize delegate:self];
    [picker pushViewController:cropViewController animated:YES];
}

#pragma mark - SHUCropImageControllerDelegate

- (void) cropViewControllerDidCropImage:(UIImage *)cropedImage{
    self.callbackBlock(cropedImage);
    [_targetViewController.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}


@end
