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
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;
    }
    return self;
}


- (void)drawRect:(CGRect)rect{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [self _drawCenterRectInContext:context];
    [self _drawOtherRectsInContext:context];
}

#pragma mark - Private

- (void) _drawCenterRectInContext:(CGContextRef )context{
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context,
                                     [UIColor whiteColor].CGColor);
    CGRect rectangle = [self _centerRect];
    CGContextAddRect(context, rectangle);
    CGContextStrokePath(context);
}

- (void) _drawOtherRectsInContext:(CGContextRef )context{
    
    CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:0.f alpha:0.5f].CGColor);
    
    CGRect rectangleLeft = [self _rectForEdgeType:SHUCropViewEdgeTypeLeft];
    
    CGRect rectangleBottom = [self _rectForEdgeType:SHUCropViewEdgeTypeBottom];
    
    CGRect rectangleRight = [self _rectForEdgeType:SHUCropViewEdgeTypeRight];
    
    CGRect rectangleTop = [self _rectForEdgeType:SHUCropViewEdgeTypeTop];
    
    CGContextAddRect(context, rectangleLeft);
    CGContextFillRect(context, rectangleLeft);
    
    CGContextAddRect(context, rectangleBottom);
    CGContextFillRect(context, rectangleBottom);
    
    CGContextAddRect(context, rectangleRight);
    CGContextFillRect(context, rectangleRight);
    
    CGContextAddRect(context, rectangleTop);
    CGContextFillRect(context, rectangleTop);
}

- (CGRect ) _centerRect{
    
    CGPoint origin;
    CGSize  size;
    origin = CGPointMake(self.center.x - self.cropSize.width / 2.f + 1.f,
                         self.center.y - self.cropSize.height / 2.f + 1.f);
    size = self.cropSize;
    
    return CGRectMake(origin.x , origin.y, size.width - 1.f, size.height - 1.f);
}

- (CGRect ) _rectForEdgeType:(SHUCropViewEdgeType )edgeType{
    
    CGPoint origin;
    CGSize  size;
    CGRect centerRect = [self _centerRect];
    
    switch (edgeType) {
        case SHUCropViewEdgeTypeLeft:
            origin = self.bounds.origin;
            size = CGSizeMake(origin.x + centerRect.origin.x,
                              self.frame.size.height);
            break;
        case SHUCropViewEdgeTypeBottom:
            origin = CGPointMake(centerRect.origin.x,
                                 centerRect.origin.y + centerRect.size.height + 1.f);
            size = CGSizeMake(centerRect.size.width,
                              self.frame.size.height - origin.y);
            break;
        case SHUCropViewEdgeTypeRight:
            origin = CGPointMake(centerRect.origin.x + centerRect.size.width,
                                 self.bounds.origin.y);
            size = CGSizeMake(self.frame.size.width - origin.x,
                              self.frame.size.height);
            break;
        case SHUCropViewEdgeTypeTop:
            origin = CGPointMake(centerRect.origin.x,
                                 self.bounds.origin.y);
            size = CGSizeMake(centerRect.size.width,
                              centerRect.origin.y);
            break;
        default:
            break;
    }
    
    return CGRectMake(origin.x , origin.y, size.width, size.height);
}

@end
