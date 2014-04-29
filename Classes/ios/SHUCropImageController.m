//
//  SHUCropImageController.m
//  Pods
//
//  Created by Sergey Shulga on 4/29/14.
//
//

#import "SHUCropImageController.h"

@interface SHUCropImageController ()

@property (weak, nonatomic) IBOutlet UIScrollView       *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView        *imageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contectViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView             *contentView;
@property (weak, nonatomic) IBOutlet UIView             *cropView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cropViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cropViewWidthConstraint;

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
    
    [self configView];
}

- (void) viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    CGSize imageSize = [self sizeOfImage:self.imageToCrop];
    
    CGFloat cropViewHeight = self.cropView.frame.size.height;
    
    CGFloat topInset, bottomInset, leftInset, rightInset;
    
    if (cropViewHeight > imageSize.height) {
        topInset = (cropViewHeight - imageSize.height) / 2.f + 64.f;
        bottomInset = (cropViewHeight - imageSize.height) / 2.f;
        leftInset = self.cropView.frame.origin.x - (self.imageView.frame.size.width - imageSize.width) / 2.f;
        rightInset = leftInset;
    }else{
        topInset = (imageSize.height - cropViewHeight) / 2.f + 64.f;
        bottomInset = (imageSize.height - cropViewHeight) / 2.f;
        leftInset = self.cropView.frame.origin.x - (self.imageView.frame.size.width - imageSize.width) / 2.f;
        rightInset = leftInset;
    }
    
    self.scrollView.contentInset = UIEdgeInsetsMake(topInset, leftInset, bottomInset, rightInset);
}

#pragma mark - Private

- (void) configView{
    self.imageView.image = self.imageToCrop;
    self.cropView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.cropView.layer.borderWidth = 0.5f;
    self.contentViewHeightConstraint.constant -= 64;
    self.cropViewWidthConstraint.constant = self.cropSize.width;
    self.cropViewHeightConstraint.constant = self.cropSize.height;
}

- (CGSize ) sizeOfImage:(UIImage *)image{
    
    CGSize actualSize = image.size;
    CGFloat width, height;
    
    if (actualSize.width > actualSize.height) {
        width = self.imageView.frame.size.width;
        height = actualSize.height * width / actualSize.width;
    
    }else{
        height = self.imageView.frame.size.height;
        width = actualSize.width * height / actualSize.height;
    }
    
    return CGSizeMake(width, height);
}

@end
