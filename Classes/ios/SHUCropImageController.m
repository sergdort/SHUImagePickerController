//
//  SHUCropImageController.m
//  Pods
//
//  Created by Sergey Shulga on 4/29/14.
//
//

#import "SHUCropImageController.h"
#import "SHUCropView.h"

@interface SHUCropImageController ()

@property (weak, nonatomic) IBOutlet UIScrollView       *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView        *imageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contectViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView             *contentView;

@property (strong, nonatomic)        UIImage            *imageToCrop;
@property (assign, nonatomic)        CGSize              cropSize;

@end

@implementation SHUCropImageController

#pragma mark - UIViewController

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil imageToCrop:(UIImage *)image cropSize:(CGSize)cropSize{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        self.imageToCrop = image;
        self.cropSize = cropSize;
    }
    
    return self;
}

- (void) viewDidLoad{
    [super viewDidLoad];
    [self _configView];
}

- (void) viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self _configScrollViewInsets];
}

#pragma mark - Private

- (void) _configView{
    self.imageView.image = self.imageToCrop;
    CGSize imageSize = [self _sizeOfImage:self.imageToCrop];
    self.contectViewWidthConstraint.constant = imageSize.width;
    self.contentViewHeightConstraint.constant = imageSize.height;
    SHUCropView *cropView = [[SHUCropView alloc] initWithFrame:[self.view bounds] cropSize:self.cropSize];
    [self.view addSubview:cropView];
}

- (void) _configScrollViewInsets {
    
    CGFloat cropViewHeight = self.cropSize.height;
    CGFloat navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    
    CGFloat topInset, bottomInset, leftInset, rightInset;

    topInset = (self.contentView.frame.size.height - cropViewHeight) / 2.f + (navigationBarHeight + statusBarHeight) / 2.f;
    bottomInset = (self.contentView.frame.size.height - cropViewHeight) / 2.f - (navigationBarHeight + statusBarHeight) / 2.f;
    leftInset = (self.scrollView.frame.size.width - self.cropSize.width) / 2.f;
    rightInset = leftInset;
  
    self.scrollView.contentInset = UIEdgeInsetsMake(topInset, leftInset, bottomInset, rightInset);
}

- (CGSize ) _sizeOfImage:(UIImage *)image{
    
    CGSize actualSize = image.size;
    CGFloat width, height;
    
    if (actualSize.width < self.view.frame.size.width) {
        width = self.view.frame.size.width;
        height = actualSize.height * width / actualSize.width;
    
    }else{
        height = actualSize.height;
        width = actualSize.width;
    }
    
    if (height < self.view.frame.size.height) {
        width = width * self.view.frame.size.height / height;
        height = self.view.frame.size.height;
    }
    
    return CGSizeMake(ceilf(width), ceilf(height));
}


@end
