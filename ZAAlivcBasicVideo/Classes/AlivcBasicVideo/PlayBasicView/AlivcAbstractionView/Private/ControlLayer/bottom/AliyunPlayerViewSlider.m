//
//  AliyunVodSlider.m
//

#import "AliyunPlayerViewSlider.h"

@interface AliyunPlayerViewSlider()
@property(nonatomic, assign) CGFloat changedValue;

@property (nonatomic, strong)UILongPressGestureRecognizer *pressGesture;
@property (nonatomic, strong)UITapGestureRecognizer *tapGesture;

@end

@implementation AliyunPlayerViewSlider

- (void)setIsSupportDot:(BOOL)isSupportDot {
    
    _isSupportDot = isSupportDot;
    if (isSupportDot == YES) {
        
        _tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
        [self addGestureRecognizer:_tapGesture];

        [_pressGesture requireGestureRecognizerToFail:_tapGesture];
    }else {
        
        [self removeGestureRecognizer:_tapGesture];
    }
    
}

- (instancetype)init{
    
    if (self =[super init]) {
    
        
        _pressGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(press:)];
        _pressGesture.minimumPressDuration = 0.01;
        
        [self addGestureRecognizer:_pressGesture];
        
        
        
    }
    return self;
}

- (void)tap:(UITapGestureRecognizer*)tap {
    
    CGPoint touchPoint = [tap locationInView:self];
    CGFloat value = (self.maximumValue - self.minimumValue) * (touchPoint.x / self.frame.size.width );
    if (value <0) {
        value = 0;
    }else if (value >1){
        value = 1;
    }
    if ([self.sliderDelegate respondsToSelector:@selector(aliyunPlayerViewSlider:event:clickedSlider:)] ) {
        [self.sliderDelegate aliyunPlayerViewSlider:self event:UIControlEventTouchDown clickedSlider:value];
    }
}

- (void)press:(UITapGestureRecognizer*)press {
    
    CGPoint touchPoint = [press locationInView:self];
    CGFloat value = (self.maximumValue - self.minimumValue) * (touchPoint.x / self.frame.size.width );
    if (value <0) {
        value = 0;
    }else if (value >1){
        value = 1;
    }
    
    switch (press.state) {
        case UIGestureRecognizerStateBegan:
            _beginPressValue = self.value;
            if ([self.sliderDelegate respondsToSelector:@selector(aliyunPlayerViewSlider:event:clickedSlider:)] ) {
                [self.sliderDelegate aliyunPlayerViewSlider:self event:UIControlEventTouchDown clickedSlider:value];
            }
            
            break;
        case UIGestureRecognizerStateChanged:
            _changedValue = value;
            if ([self.sliderDelegate respondsToSelector:@selector(aliyunPlayerViewSlider:event:clickedSlider:)] ) {
                [self.sliderDelegate aliyunPlayerViewSlider:self event:UIControlEventValueChanged clickedSlider:value];
                
            }
            
            break;
        case UIGestureRecognizerStateEnded:
            
            if ([self.sliderDelegate respondsToSelector:@selector(aliyunPlayerViewSlider:event:clickedSlider:)] ) {
                [self.sliderDelegate aliyunPlayerViewSlider:self event:UIControlEventTouchUpInside clickedSlider:value];
            }
            
             break;
        case UIGestureRecognizerStateFailed:{
            
        }
            break;
            
        case UIGestureRecognizerStateCancelled:{
          
            if ([self.sliderDelegate respondsToSelector:@selector(aliyunPlayerViewSlider:event:clickedSlider:)] ) {
                [self.sliderDelegate aliyunPlayerViewSlider:self event:UIControlEventTouchUpInside clickedSlider:_changedValue];
            }
            
        }
            break;
            
        default:
            break;
    }
    
    
    
             
}





@end
