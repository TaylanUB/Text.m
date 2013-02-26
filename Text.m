#import "Text.h"

static const CFRange MyZeroRange = {0, 0};

@interface Text ()

- (void) makeTypesetter;

@end

@implementation Text
{
  CTTypesetterRef typesetter;
}

@synthesize font;
@synthesize text;
@synthesize textAlignment;
@synthesize textColor;

@synthesize width;

@synthesize leading;
@synthesize kerning;

@synthesize capHeight;
@synthesize ascent;
@synthesize descent;

#pragma mark - Init / Dealloc

+ (Text *) textWithText:(NSString *)text
{
  Text *t = [[self alloc] init];
  t.text = text;
  return t;
}

- (id) initWithFrame:(CGRect)frame
{
  if ( ! (self = [super initWithFrame:frame]) )
    return nil;

  self.backgroundColor = [UIColor clearColor];

  text = @"";
  textColor = [UIColor blackColor];

  leading = 3;

  width = frame.size.width;

  self.font = [UIFont systemFontOfSize:17];

  return self;
}
- (void) dealloc
{

  if (typesetter)
    CFRelease(typesetter);

}

# pragma mark - Getters / Setters

- (void) setFont:(UIFont *)_font
{
  if (_font == nil)
    [NSException raise:@"You may not set the font to nil." format:nil];
  
  font = _font;
  {
    CTFontDescriptorRef descriptor = CTFontDescriptorCreateWithNameAndSize((__bridge CFStringRef)font.fontName, font.pointSize);
    CTFontRef ctfont = CTFontCreateWithFontDescriptor(descriptor, font.pointSize, NULL);
    capHeight = ceilf(CTFontGetCapHeight(ctfont));
    ascent = ceilf(CTFontGetAscent(ctfont) - CTFontGetCapHeight(ctfont));
    descent = ceilf(CTFontGetDescent(ctfont));
    CFRelease(ctfont);
    CFRelease(descriptor);
  }
  [self makeTypesetter];
}

- (void) setText:(NSString *)_text
{
  if (_text) {
    text = [_text copy];
    [self makeTypesetter];
  } else {
    self.text = @"";
  }
}

- (void) setTextAlignment:(UITextAlignment)_textAlignment
{
  textAlignment = _textAlignment;
  [self makeTypesetter];
}

- (void) setTextColor:(UIColor *)_textColor
{
  textColor = _textColor;
  [self makeTypesetter];
}

- (void) setWidth:(CGFloat)_width
{
  width = _width;
  [self sizeToFit];
}

- (void) setLineHeight:(CGFloat)lineHeight
{
  self.leading = lineHeight - (capHeight + descent);
}
- (CGFloat) lineHeight
{
  return capHeight + descent + leading;
}

- (void) setLeading:(CGFloat)_leading
{
  leading = _leading;
  [self makeTypesetter];
}

- (void) setKerning:(CGFloat)_kerning
{
  kerning = _kerning;
  [self makeTypesetter];
}

#pragma mark - Size Fitting

- (void) sizeToFit
{
  [super sizeToFit];
  [self setNeedsDisplay];
}

- (CGSize) sizeThatFits:(CGSize)size
{
  return (width != 0
          ? [self sizeThatHasWidth:width]
          : [self sizeThatFitsWidth:CGFLOAT_MAX]);
}

- (CGSize) sizeThatFitsWidth:(CGFloat)_width
{
  CGFloat w = 0, h = ascent;

  CFIndex start = 0;
  while (start < text.length) {
    CFIndex count = CTTypesetterSuggestLineBreak(typesetter, start, _width);
    CTLineRef line = CTTypesetterCreateLine(typesetter, CFRangeMake(start, count));
    w = MAX(w, CTLineGetTypographicBounds(line, NULL, NULL, NULL));
    CFRelease(line);
    h += capHeight + descent + leading;
    start += count;
  }
  h -= leading;

  return CGSizeMake(ceilf(w), ceilf(h));
}
- (CGSize) sizeThatHasWidth:(CGFloat)_width
{
  CGSize size = [self sizeThatFitsWidth:_width];
  size.width = _width;
  return size;
}

#pragma mark - Draw Rect

- (void) drawRect:(CGRect)rect
{
  CGContextRef context = UIGraphicsGetCurrentContext();

  CGAffineTransform textMatrix = CGAffineTransformIdentity;
  textMatrix = CGAffineTransformScale(textMatrix, 1, -1);
  CGContextSetTextMatrix(context, textMatrix);

  // Add capHeight to y because we can't set translation in the textMatrix
  CGFloat y = rect.origin.y + capHeight;
  CGFloat flush = 0;
  switch (textAlignment) {
  case UITextAlignmentCenter:
    flush = .5;
    break;
  case UITextAlignmentRight:
    flush = 1;
    break;
  default:
    break;
  }
  
  CFIndex start = 0;
  y += ascent;
  while (start < text.length) {
    CFIndex count = CTTypesetterSuggestLineBreak(typesetter, start, rect.size.width);
    CTLineRef line = CTTypesetterCreateLine(typesetter, CFRangeMake(start, count));
    double penOffset = 0;
    if (flush)
      penOffset = CTLineGetPenOffsetForFlush(line, flush, rect.size.width);
    CGContextSetTextPosition(context, rect.origin.x + penOffset, y);
    CTLineDraw(line, context);
    CFRelease(line);
    y += capHeight + descent + leading;
    start += count;
  }
}

#pragma mark - aux

- (void) makeTypesetter
{
  CFMutableAttributedStringRef aStr = CFAttributedStringCreateMutable(NULL, 0);
  CFAttributedStringReplaceString(aStr, MyZeroRange, (CFStringRef)text);

  CFRange fullRange = CFRangeMake(0, text.length);

  {
    CTFontDescriptorRef descriptor = CTFontDescriptorCreateWithNameAndSize((__bridge CFStringRef)font.fontName, font.pointSize);
    CTFontRef ctfont = CTFontCreateWithFontDescriptor(descriptor, font.pointSize, NULL);
    CFAttributedStringSetAttribute(aStr, fullRange, kCTFontAttributeName, ctfont);
    CFRelease(ctfont);
    CFRelease(descriptor);
  }

  CFAttributedStringSetAttribute(aStr, fullRange, kCTForegroundColorAttributeName, textColor.CGColor);

  {
    CFNumberRef num = CFNumberCreate(NULL, kCFNumberFloatType, &kerning);
    CFAttributedStringSetAttribute(aStr, fullRange, kCTKernAttributeName, num);
    CFRelease(num);
  }

  if (typesetter)
    CFRelease(typesetter);
  typesetter = CTTypesetterCreateWithAttributedString(aStr);

  CFRelease(aStr);

  [self sizeToFit];
}

@end
