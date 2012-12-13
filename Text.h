#import <CoreText/CoreText.h>
#import <UIKit/UIKit.h>

@interface Text : UIView

+ (Text *) text:(NSString *)text;

@property (nonatomic, strong) UIFont *font;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, assign) UITextAlignment textAlignment;
@property (nonatomic, strong) UIColor *textColor;

@property (nonatomic, assign) CGFloat width;

@property (nonatomic, assign) CGFloat lineHeight;
@property (nonatomic, assign) CGFloat leading;
@property (nonatomic, assign) CGFloat kerning;

@property (nonatomic, readonly) CGFloat capHeight;
@property (nonatomic, readonly) CGFloat ascent;
@property (nonatomic, readonly) CGFloat descent;

- (CGSize) sizeThatFitsWidth:(CGFloat)width;
- (CGSize) sizeThatHasWidth:(CGFloat)width;

@end
