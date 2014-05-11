//
//  SHUCropImageController.m
//  Pods
//
//  Created by Sergey Shulga on 4/29/14.
//
//

#import "SHUCropImageController.h"
#import "SHUCropView.h"

@interface SHUCropImageController () <UIScrollViewDelegate>

@property (weak, nonatomic)   IBOutlet UIScrollView       *scrollView;
@property (weak, nonatomic)   IBOutlet UIImageView        *imageView;
@property (weak, nonatomic)   IBOutlet NSLayoutConstraint *contectViewWidthConstraint;
@property (weak, nonatomic)   IBOutlet NSLayoutConstraint *contentViewHeightConstraint;
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
        self.imageToCrop = image;
        self.cropSize = cropSize;
        self.delegate = delegate;
    }
    
    return self;
}

- (void) viewDidLoad{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)];
    [self _configScrollViewZoom];
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self _configView];
    [self _configScrollViewInsets];
}


#pragma mark - Private

- (void) _configView{
    self.imageView.image = self.imageToCrop;
    CGSize imageSize = [self _contentSizeForImage:self.imageToCrop];
    self.contectViewWidthConstraint.constant = imageSize.width;
    self.contentViewHeightConstraint.constant = imageSize.height;
    SHUCropView *cropView = [[SHUCropView alloc] initWithFrame:[self.view bounds] cropSize:self.cropSize];
    [self.view addSubview:cropView];
}

- (void) _configScrollViewZoom{
    if (self.cropSize.width > self.cropSize.height) {
        self.scrollView.minimumZoomScale =  self.cropSize.width / self.contectViewWidthConstraint.constant;
    }else{
        self.scrollView.minimumZoomScale =  self.cropSize.height / self.contectViewWidthConstraint.constant;
    }
    CGFloat maxZoomFactor = MAX(self.imageToCrop.size.width, self.imageToCrop.size.height) / MAX(self.cropSize.width, self.cropSize.height);
    self.scrollView.maximumZoomScale = maxZoomFactor < 2 ? 10.f : maxZoomFactor;
}

- (void) _configScrollViewInsets {
    BOOL isIPad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
    CGFloat cropViewHeight = self.cropSize.height;
    CGFloat navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    
    CGFloat topInset, bottomInset, leftInset, rightInset;
    
    if (isIPad) {
        bottomInset = (self.contentView.frame.size.height - cropViewHeight) / 2.f - (568.f - self.view.frame.size.height) / 2.f;
        
        topInset = bottomInset;
    }else{
        bottomInset = (self.contentView.frame.size.height - cropViewHeight) / 2.f - (568.f - self.view.frame.size.height) / 2.f;
        
        topInset = bottomInset - (navigationBarHeight + statusBarHeight);
    }
    
    leftInset = (self.scrollView.frame.size.width - self.cropSize.width) / 2.f;
    rightInset = leftInset;
  
    self.scrollView.contentInset = UIEdgeInsetsMake(topInset, leftInset, bottomInset, rightInset);
}

- (void) _cropImage{
    [self.activityIndicator startAnimating];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CGImageRef cropedImageRef = CGImageCreateWithImageInRect(self.imageToCrop.CGImage,
                                                                 [self _cropRect]);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.activityIndicator stopAnimating];
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
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - UIScrollViewDelegate

- (UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.contentView;
}


@end
