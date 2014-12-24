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

#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

@interface SHUImagePicker () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, SHUCropImageControllerDelegate>

@property (strong, nonatomic)   UIImagePickerController *imagePickerController;
@property (weak,   nonatomic)   UIViewController        *targetViewController;
@property (strong, nonatomic)   UIPopoverController     *popoverController;
@property (assign, nonatomic)   CGSize                   cropSize;

@property (copy,   nonatomic)   void(^callbackBlock)(UIImage *cropedImage);

@end

@implementation SHUImagePicker

#pragma mark - Public

- (void) showPickerInViewController:(UIViewController *)viewController
                      forSourceType:(UIImagePickerControllerSourceType )sourceType
                           cropSize:(CGSize)cropSize
                           fromRect:(CGRect)rect
                       withCallback:(void (^)(UIImage *))callback{
    
    self.targetViewController = viewController;
    self.callbackBlock = callback;
    self.imagePickerController = [[UIImagePickerController alloc] init];
    self.imagePickerController.delegate = self;
    self.imagePickerController.sourceType = sourceType;
    self.cropSize = cropSize;
    
    [self _presentImagePickerControllerFromRect:rect];
}

- (void) showPickerInViewController:(UIViewController *)viewController
                      forSourceType:(UIImagePickerControllerSourceType )sourceType
                           cropSize:(CGSize)cropSize
                           fromView:(UIView *)view
                       withCallback:(void (^)(UIImage *))callback {
    self.targetViewController = viewController;
    self.callbackBlock = callback;
    self.imagePickerController = [[UIImagePickerController alloc] init];
    self.imagePickerController.delegate = self;
    self.imagePickerController.sourceType = sourceType;
    self.cropSize = cropSize;
    
    [self _presentImagePickerControllerFromView:view];
}

- (void) showPickerInViewController:(UIViewController *)viewController
                      forSourceType:(UIImagePickerControllerSourceType)sourceType
                           cropSize:(CGSize)cropSize
                      barButtonItem:(UIBarButtonItem *)barButtonItem
                       withCallback:(void (^)(UIImage *))callback {
    self.targetViewController = viewController;
    self.callbackBlock = callback;
    self.imagePickerController = [[UIImagePickerController alloc] init];
    self.imagePickerController.delegate = self;
    self.imagePickerController.sourceType = sourceType;
    self.cropSize = cropSize;
    
    [self _presentImagePickerControllerFromBarButtonItem:barButtonItem];
}

#pragma mark - Private

- (void) _presentImagePickerControllerFromRect:(CGRect) rect {
    
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.popoverController = [[UIPopoverController alloc] initWithContentViewController:self.imagePickerController];
            [self.popoverController presentPopoverFromRect:rect inView:self.targetViewController.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }else{
            [self.targetViewController presentViewController:self.imagePickerController animated:YES completion:nil];
        }
    } else {
        self.imagePickerController.modalPresentationStyle = UIModalPresentationPopover;
        self.imagePickerController.popoverPresentationController.sourceRect = rect;
        [self.targetViewController presentViewController:self.imagePickerController animated:YES completion:nil];
    }
    
}

- (void) _presentImagePickerControllerFromView:(UIView *)view {
    
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.popoverController = [[UIPopoverController alloc] initWithContentViewController:self.imagePickerController];
            [self.popoverController presentPopoverFromRect:view.frame
                                                    inView:self.targetViewController.view
                                  permittedArrowDirections:UIPopoverArrowDirectionAny
                                                  animated:YES];
        }else{
            [self.targetViewController presentViewController:self.imagePickerController animated:YES completion:nil];
        }
    } else {
        self.imagePickerController.modalPresentationStyle = UIModalPresentationPopover;
        self.imagePickerController.popoverPresentationController.sourceView = view;
        [self.targetViewController presentViewController:self.imagePickerController animated:YES completion:nil];
    }
}

- (void) _presentImagePickerControllerFromBarButtonItem:(UIBarButtonItem *)barButtonItem {
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.popoverController = [[UIPopoverController alloc] initWithContentViewController:self.imagePickerController];
            [self.popoverController presentPopoverFromBarButtonItem:barButtonItem
                                           permittedArrowDirections:UIPopoverArrowDirectionAny
                                                           animated:YES];
        }else{
            [self.targetViewController presentViewController:self.imagePickerController animated:YES completion:nil];
        }
    } else {
        self.imagePickerController.modalPresentationStyle = UIModalPresentationPopover;
        self.imagePickerController.popoverPresentationController.barButtonItem = barButtonItem;
        [self.targetViewController presentViewController:self.imagePickerController animated:YES completion:nil];
    }
}

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

- (void) _performDrillInWithPhoto:(UIImage *)photo pickerController:(UIImagePickerController *)picker {
    SHUCropImageController *cropViewController = [[SHUCropImageController alloc] initWithNibName:nil bundle:nil imageToCrop:photo cropSize:_cropSize delegate:self];
    [picker pushViewController:cropViewController animated:YES];
}

#pragma mark - UIImagePickerControllerDelegate

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
        [self _performDrillInWithPhoto:originalImage pickerController:picker];
    } else {
        NSURL *imageUrl = info[UIImagePickerControllerReferenceURL];
        [self _performDrillInWithPhotoUrl:imageUrl pickerController:picker];
    }
}

#pragma mark - SHUCropImageControllerDelegate

- (void) cropViewControllerDidCropImage:(UIImage *)cropedImage{
    if (self.callbackBlock) {
        self.callbackBlock(cropedImage);
    }
    [self.targetViewController.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}


@end
