//
//  SHUCropImageController.m
//  Pods
//
//  Created by Sergey Shulga on 4/29/14.
//
//

#import "SHUCropImageController.h"
#import "SHUCropView.h"
#import "Masonry.h"

@interface SHUCropImageController () <UIScrollViewDelegate>

@property (weak, nonatomic)   IBOutlet UIScrollView       *scrollView;
@property (weak, nonatomic)   IBOutlet UIImageView        *imageView;
@property (weak, nonatomic)   IBOutlet NSLayoutConstraint *contectViewWidthConstraint;
@property (weak, nonatomic)   IBOutlet NSLayoutConstraint *contentViewHeightConstraint;
@property (unsafe_unretained, nonatomic) IBOutlet NSLayoutConstraint *contentViewTopConstraint;

@property (weak, nonatomic)   IBOutlet UIView             *contentView;

@property (strong, nonatomic)          UIImage            *imageToCrop;
@property (assign, nonatomic)          CGSize              cropSize;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (weak, nonatomic)   id<SHUCropImageControllerDelegate> delegate;

@end

@implementation SHUCropImageController

#pragma mark - UIViewController

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil imageToCrop:(UIImage *)image cropSize:(CGSize )cropSize delegate:(id <SHUCropImageControllerDelegate> )delegate{
   
   self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
   
   if (self) {
      self.imageToCrop = [self _imageWithFixedOrientationFromImage:image];
      self.cropSize = cropSize;
      self.delegate = delegate;
   }
   
   return self;
}

- (void) viewDidLoad{
   [super viewDidLoad];
   self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)];
}

- (void) viewWillAppear:(BOOL)animated{
   [super viewWillAppear:animated];
   
   [self _configView];
   [self _configScrollViewZoom];
   [self _configScrollViewInsets];
}

#pragma mark - Private

- (UIImage *) _imageWithFixedOrientationFromImage:(UIImage *)image {
   if (!image || image.imageOrientation == UIImageOrientationUp) {
      return image;
   }
   
   CGSize size = image.size;
   CGAffineTransform transform = CGAffineTransformIdentity;
   CGContextRef context = CGBitmapContextCreate(NULL,
                                                size.width,
                                                size.height,
                                                CGImageGetBitsPerComponent(image.CGImage),
                                                0,
                                                CGImageGetColorSpace(image.CGImage),
                                                CGImageGetBitmapInfo(image.CGImage));
   
   // Rotate the image if it's not UIImageOrientationUp
   switch (image.imageOrientation) {
      case UIImageOrientationDown:
      case UIImageOrientationDownMirrored:
         transform = CGAffineTransformTranslate(transform, size.width, size.height);
         transform = CGAffineTransformRotate(transform, M_PI);
         break;
         
      case UIImageOrientationLeft:
      case UIImageOrientationLeftMirrored:
         transform = CGAffineTransformTranslate(transform, size.width, 0);
         transform = CGAffineTransformRotate(transform, M_PI_2);
         break;
         
      case UIImageOrientationRight:
      case UIImageOrientationRightMirrored:
         transform = CGAffineTransformTranslate(transform, 0, size.height);
         transform = CGAffineTransformRotate(transform, -M_PI_2);
         break;
         
      default:
         break;
   }
   
   // Flip mirrored orientations
   switch (image.imageOrientation) {
      case UIImageOrientationUpMirrored:
      case UIImageOrientationDownMirrored:
         transform = CGAffineTransformTranslate(transform, size.width, 0);
         transform = CGAffineTransformScale(transform, -1, 1);
         break;
         
      case UIImageOrientationLeftMirrored:
      case UIImageOrientationRightMirrored:
         transform = CGAffineTransformTranslate(transform, size.height, 0);
         transform = CGAffineTransformScale(transform, -1, 1);
         break;
         
      default:
         break;
   }
   
   CGContextConcatCTM(context, transform);
   CGRect rect;
   
   switch (image.imageOrientation) {
      case UIImageOrientationLeft:
      case UIImageOrientationLeftMirrored:
      case UIImageOrientationRight:
      case UIImageOrientationRightMirrored:
         rect = CGRectMake(0, 0, size.height, size.width);
         break;
      default:
         rect = CGRectMake(0, 0, size.width, size.height);
         break;
   }
   
   CGContextDrawImage(context, rect, image.CGImage);
   CGImageRef imageRef = CGBitmapContextCreateImage(context);
   
   image = [UIImage imageWithCGImage:imageRef];
   CGContextRelease(context);
   CGImageRelease(imageRef);
   
   return image;
}

- (void) _configView{
   self.activityIndicator.hidden = YES;
   self.imageView.image = self.imageToCrop;
   CGSize imageSize = [self _contentSizeForImage:self.imageToCrop];
   self.contectViewWidthConstraint.constant = imageSize.width;
   self.contentViewHeightConstraint.constant = imageSize.height;
   self.contentViewTopConstraint.constant -= [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ? 44 : 0;
   SHUCropView *cropView = [[SHUCropView alloc] initWithFrame:[self.view bounds] cropSize:self.cropSize];
   [self.view addSubview:cropView];
   [cropView mas_makeConstraints:^(MASConstraintMaker *make) {
      make.edges.equalTo(self.view);
   }];
}

- (void) _configScrollViewZoom{
   self.scrollView.minimumZoomScale = 1.f;
   CGFloat maxZoomFactor = MAX(self.imageToCrop.size.width, self.imageToCrop.size.height) / MAX(self.cropSize.width, self.cropSize.height);
   self.scrollView.maximumZoomScale = maxZoomFactor < 2 ? 10.f : maxZoomFactor;
}

- (void) _configScrollViewInsets {
   BOOL isIPad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
   CGFloat cropViewHeight = self.cropSize.height;
   CGFloat navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
   CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
   
   CGFloat topInset, bottomInset, leftInset, rightInset;
   CGSize screenSize = [UIScreen mainScreen].bounds.size;
   
   bottomInset = (screenSize.height - self.cropSize.height) / 2.f;
   topInset = isIPad ? bottomInset : bottomInset - (navigationBarHeight + statusBarHeight);
   leftInset = (screenSize.width - self.cropSize.width) / 2.f ;
   rightInset = leftInset;
   
   self.scrollView.contentInset = UIEdgeInsetsMake(topInset, leftInset, bottomInset, rightInset);
}

- (void) _cropImage{
   self.activityIndicator.hidden = NO;
   [self.activityIndicator startAnimating];
   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      CGImageRef cropedImageRef = CGImageCreateWithImageInRect(self.imageToCrop.CGImage,
                                                               [self _cropRect]);
      dispatch_async(dispatch_get_main_queue(), ^{
         [self.activityIndicator stopAnimating];
         self.activityIndicator.hidden = YES;
         [self.delegate cropViewControllerDidCropImage:[[UIImage alloc] initWithCGImage:cropedImageRef]];
         CGImageRelease(cropedImageRef);
      });
   });
}

- (CGSize) _contentSizeForImage:(UIImage *)image{
   
   CGSize actualSize = image.size;
   CGFloat width, height;
   
   if (actualSize.width > self.cropSize.width) {
      width = self.cropSize.width;
      height = actualSize.height * width / actualSize.width;
      
   }
   else{
      height = actualSize.height;
      width = actualSize.width;
   }
   
   if (height < self.cropSize.height) {
      width = width * self.cropSize.height / height;
      height = self.cropSize.height;
   }
   return CGSizeMake(ceilf(width), ceilf(height));
}

- (CGRect) _cropRect{
   CGFloat scaleFactor = self.imageToCrop.size.width / [self _contentSizeForImage:self.imageToCrop].width;
   CGFloat zoomFactor = self.scrollView.zoomScale;
   CGFloat x = fabs(self.scrollView.contentOffset.x + self.scrollView.contentInset.left) * scaleFactor;
   CGFloat y = fabs(self.scrollView.contentOffset.y + self.scrollView.contentInset.top) * scaleFactor;
   
   return CGRectMake(x / zoomFactor, y / zoomFactor,
                     self.cropSize.width * scaleFactor / zoomFactor,
                     self.cropSize.height * scaleFactor / zoomFactor);
}


#pragma mark - Button actions

- (void) doneButtonPressed:(id)sender{
   [self _cropImage];
   [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UIScrollViewDelegate

- (UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView{
   return self.contentView;
}


@end
