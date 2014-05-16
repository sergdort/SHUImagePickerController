//
//  SHUCropView.m
//  Pods
//
//  Created by Sergey Shulga on 5/8/14.
//
//

#import "SHUCropView.h"

typedef NS_ENUM(NSInteger, SHUCropViewEdgeType) {
    SHUCropViewEdgeTypeLeft = 0,
    SHUCropViewEdgeTypeBottom,
    SHUCropViewEdgeTypeRight,
    SHUCropViewEdgeTypeTop
};

@interface SHUCropView ()

@property (assign, nonatomic) CGSize cropSize;

@end

@implementation SHUCropView

- (id)initWithFrame:(CGRect)frame cropSize:(CGSize )cropSize{
    self = [super initWithFrame:frame];
    if (self) {
        self.cropSize = cropSize;
        self.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.5];
        self.userInteractionEnabled = NO;
    }
    return self;
}


- (void)drawRect:(CGRect)rect{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [self _drawCenterRectInContext:context];
}

#pragma mark - Private

- (void) _drawCenterRectInContext:(CGContextRef )context{
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context,
                                     [UIColor whiteColor].CGColor);
    CGRect rectangle = [self _centerRect];
    
    CGContextClearRect(context, rectangle);
    CGContextAddRect(context, rectangle);
    CGContextStrokePath(context);
}

- (CGRect ) _centerRect{
    
    CGPoint origin;
    CGSize  size;
    origin = CGPointMake(self.center.x - self.cropSize.width / 2.f + 1.f,
                         self.center.y - self.cropSize.height / 2.f + 1.f);
    size = self.cropSize;
    
    return CGRectMake(origin.x , origin.y, size.width - 1.f, size.height - 1.f);
}

@end
