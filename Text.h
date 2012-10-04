#import <CoreText/CoreText.h>
#import <UIKit/UIKit.h>

@interface Text : UIView

@property (nonatomic, strong) UIFont *font;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, assign) UITextAlignment textAlignment;
@property (nonatomic, strong) UIColor *textColor;

@property (nonatomic, assign) CGFloat width;

@property (nonatomic, assign) CGFloat lineHeight;
@property (nonatomic, assign) CGFloat leading;
@property (nonatomic, assign) CGFloat kerning;

- (CGSize) sizeThatFitsWidth:(CGFloat)width;
- (CGSize) sizeThatHasWidth:(CGFloat)width;

@end
