//
//  SHUImagePicker.m
//  Pods
//
//  Created by Sergey Shulga on 4/28/14.
//
//

#import <AssetsLibrary/AssetsLibrary.h>
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

#pragma mark - Public

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


#pragma mark - Private

- (void) _performDrillInWithPhotoUrl:(NSURL *)photoUrl pickerController:(UIImagePickerController *)picker {
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library assetForURL:photoUrl resultBlock:^(ALAsset *asset) {
        
        ALAssetRepresentation *representation = [asset defaultRepresentation];
        _imageToCrop = [UIImage imageWithCGImage:[representation fullResolutionImage]
                                          scale:[representation scale]
                                    orientation:UIImageOrientationUp];
        
        SHUCropImageController *cropViewController = [[SHUCropImageController alloc] initWithNibName:nil bundle:nil imageToCrop:_imageToCrop cropSize:_cropSize delegate:self];
        [picker pushViewController:cropViewController animated:YES];
        
    } failureBlock:^(NSError *error) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        [alertView show];
        
    }];
}

#pragma mark - UIImagePickerControllerDelegate

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSURL *imageUrl = info[UIImagePickerControllerReferenceURL];
    [self _performDrillInWithPhotoUrl:imageUrl pickerController:picker];
}

#pragma mark - SHUCropImageControllerDelegate

- (void) cropViewControllerDidCropImage:(UIImage *)cropedImage{
    self.callbackBlock(cropedImage);
    [_targetViewController.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}


@end
