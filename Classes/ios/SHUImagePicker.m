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

@interface SHUImagePicker () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, SHUCropImageControllerDelegate>

@property (strong, nonatomic)   UIImagePickerController *imagePickerController;
@property (weak,   nonatomic)   UIViewController        *targetViewController;
@property (strong, nonatomic)   UIPopoverController     *popoverController;
@property (assign, nonatomic)   CGSize                   cropSize;

@property (copy,   nonatomic)   void(^callbackBlock)(UIImage *cropedImage);

@end

@implementation SHUImagePicker

#pragma mark - Public

- (void) showPickerInViewController:(UIViewController *)viewController forSourceType:(UIImagePickerControllerSourceType )sourceType cropSize:(CGSize)cropSize fromRect:(CGRect)rect withCallback:(void (^)(UIImage *))callback{
    
    self.targetViewController = viewController;
    self.callbackBlock = callback;
    self.imagePickerController = [[UIImagePickerController alloc] init];
    self.imagePickerController.delegate = self;
    self.imagePickerController.sourceType = sourceType;
    self.cropSize = cropSize;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.popoverController = [[UIPopoverController alloc] initWithContentViewController:self.imagePickerController];
        [self.popoverController presentPopoverFromRect:rect inView:self.targetViewController.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }else{
        [self.targetViewController presentViewController:self.imagePickerController animated:YES completion:nil];
    }
}


#pragma mark - Private

- (void) _performDrillInWithPhotoUrl:(NSURL *)photoUrl pickerController:(UIImagePickerController *)picker {
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library assetForURL:photoUrl resultBlock:^(ALAsset *asset) {
        
        ALAssetRepresentation *representation = [asset defaultRepresentation];
        NSNumber *orientationValue = [asset valueForProperty:ALAssetPropertyOrientation];
        UIImageOrientation orientation = orientationValue ? [orientationValue integerValue] : UIImageOrientationUp;
        UIImage *imageToCrop = [UIImage imageWithCGImage:[representation fullResolutionImage]
                                                   scale:[representation scale]
                                             orientation:orientation];
        
        SHUCropImageController *cropViewController = [[SHUCropImageController alloc] initWithNibName:nil bundle:nil imageToCrop:imageToCrop cropSize:_cropSize delegate:self];
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
    if (self.callbackBlock) {
        self.callbackBlock(cropedImage);
    }
    [self.targetViewController.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}


@end
