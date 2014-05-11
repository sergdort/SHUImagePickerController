//
//  SHUCropImageController.h
//  Pods
//
//  Created by Sergey Shulga on 4/29/14.
//
//

#import <UIKit/UIKit.h>

@protocol SHUCropImageControllerDelegate <NSObject>

- (void) cropViewControllerDidCropImage:(UIImage *)cropedImage;

@end

@interface SHUCropImageController : UIViewController

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil imageToCrop:(UIImage *)image cropSize:(CGSize )cropSize delegate:(id <SHUCropImageControllerDelegate> )delegate;

@end
