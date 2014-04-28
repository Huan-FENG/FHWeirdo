//
//  RCLabel.m
//  RCLabelProject
//
/**
 * Copyright (c) 2012 Hang Chen
 * Created by hangchen on 21/7/12.
 * 
 * Permission is hereby granted, free of charge, to any person obtaining 
 * a copy of this software and associated documentation files (the 
 * "Software"), to deal in the Software without restriction, including 
 * without limitation the rights to use, copy, modify, merge, publish, 
 * distribute, sublicense, and/or sell copies of the Software, and to 
 * permit persons to whom the Software is furnished to do so, subject 
 * to the following conditions:
 *
 * The above copyright notice and this permission notice shall be 
 * included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT 
 * WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR 
 * PURPOSE AND NONINFRINGEMENT. IN NO EVENT 
 * SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE 
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR 
 * IN CONNECTION WITH THE SOFTWARE OR 
 * THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 * 
 * @author 		Hang Chen <cyndibaby905@yahoo.com.cn>
 * @copyright	2012	Hang Chen
 * @version
 * 
 */

#import "RCLabel.h"
#define LINK_PADDING 100
#define IMAGE_PADDING 2
#define IMAGE_USER_WIDTH 180.0
#define IMAGE_MAX_WIDTH ((IMAGE_USER_WIDTH) - 8 *(IMAGE_PADDING))
#define IMAGE_USER_HEIGHT 80.0
#define IMAGE_LINK_BOUND_MIN_HEIGHT 30
#define IMAGE_USER_DESCENT ((IMAGE_USER_HEIGHT) / 20.0)
#define IMAGE_MAX_HEIGHT ((IMAGE_USER_HEIGHT + IMAGE_USER_DESCENT) - 2 * (IMAGE_PADDING))

#define BG_COLOR 0xDDDDDD
#define IMAGE_MIN_WIDTH 5
#define IMAGE_MIN_HEIGHT 5




static NSMutableDictionary *imgSizeDict = NULL;

@implementation RCLabelComponent

@synthesize text;
@synthesize tagLabel;
@synthesize attributes;
@synthesize position;
@synthesize componentIndex;
@synthesize isClosure;
@synthesize img;

- (id)initWithString:(NSString*)aText tag:(NSString*)aTagLabel attributes:(NSMutableDictionary*)theAttributes;
{
    self = [super init];
	if (self) {
		self.text = aText;
		self.tagLabel = aTagLabel;
		self.attributes = theAttributes;
        self.isClosure = NO;
	}
	return self;
}

+ (id)componentWithString:(NSString*)aText tag:(NSString*)aTagLabel attributes:(NSMutableDictionary*)theAttributes
{
	return [[self alloc] initWithString:aText tag:aTagLabel attributes:theAttributes];
}

- (id)initWithTag:(NSString*)aTagLabel position:(int)aPosition attributes:(NSMutableDictionary*)theAttributes
{
    self = [super init];
    if (self) {
        self.tagLabel = aTagLabel;
		self.position = aPosition;
		self.attributes = theAttributes;
        self.isClosure = NO;
    }
    return self;
}

+(id)componentWithTag:(NSString*)aTagLabel position:(int)aPosition attributes:(NSMutableDictionary*)theAttributes
{
	return [[self alloc] initWithTag:aTagLabel position:aPosition attributes:theAttributes];
}



- (NSString*)description
{
	NSMutableString *desc = [NSMutableString string];
	[desc appendFormat:@"text: %@", self.text];
	[desc appendFormat:@", position: %i", self.position];
	if (self.tagLabel) [desc appendFormat:@", tag: %@", self.tagLabel];
	if (self.attributes) [desc appendFormat:@", attributes: %@", self.attributes];
	return desc;
}

- (void)dealloc 
{
    self.text = nil;
    self.tagLabel = nil;
    self.attributes = nil;
    self.img = nil;
}

@end
@implementation RCLabelComponentsStructure
@synthesize components = components_;
@synthesize plainTextData = plainTextData_;
@synthesize linkComponents = linkComponents_;
@synthesize imgComponents = imgComponents_;

- (void)dealloc {
    self.plainTextData = nil;
    self.components = nil;
    self.linkComponents = nil;
    self.imgComponents = nil;
}


@end 

static NSInteger totalCount = 0;

@interface RCLabel()
@property (nonatomic, assign) CGSize optimumSize;

//- (NSArray *)components;
//- (void)parse:(NSString *)data valid_tags:(NSArray *)valid_tags;
- (NSArray*) colorForHex:(NSString *)hexColor;
- (void)render:(BOOL)isYes;
- (CGRect)BoundingRectForLink:(RCLabelComponent*)linkComponent withRun:(CTRunRef)run;
- (CGRect)BoundingRectFroImage:(RCLabelComponent*)imgComponent withRun:(CTRunRef)run;

- (void)genAttributedString;

- (CGPathRef)newPathForRoundedRect:(CGRect)rect radius:(CGFloat)radius;

- (void)dismissBoundRectForTouch;
#pragma mark -
#pragma mark styling

- (void)applyItalicStyleToText:(CFMutableAttributedStringRef)text atPosition:(int)position withLength:(int)length;
- (void)applyBoldStyleToText:(CFMutableAttributedStringRef)text atPosition:(int)position withLength:(int)length;
- (void)applyColor:(NSString*)value toText:(CFMutableAttributedStringRef)text atPosition:(int)position withLength:(int)length;
- (void)applySingleUnderlineText:(CFMutableAttributedStringRef)text atPosition:(int)position withLength:(int)length;
- (void)applyDoubleUnderlineText:(CFMutableAttributedStringRef)text atPosition:(int)position withLength:(int)length;
- (void)applyUnderlineColor:(NSString*)value toText:(CFMutableAttributedStringRef)text atPosition:(int)position withLength:(int)length;
- (void)applyFontAttributes:(NSDictionary*)attributes toText:(CFMutableAttributedStringRef)text atPosition:(int)position withLength:(int)length;
- (void)applyParagraphStyleToText:(CFMutableAttributedStringRef)text attributes:(NSMutableDictionary*)attributes atPosition:(int)position withLength:(int)length;
- (void)applyImageAttributes:(CFMutableAttributedStringRef)text attributes:(NSMutableDictionary*)attributes atPosition:(int)position withLength:(int)length;
- (void)applyLinkAttributes:(CFMutableAttributedStringRef)text attributes:(NSMutableDictionary*)attributes atPosition:(int)position withLength:(int)length;
@end

@implementation RCLabel



@synthesize optimumSize;
@synthesize sizeDelegate;
@synthesize delegate;
@synthesize paragraphReplacement;
@synthesize currentImgComponent;
@synthesize currentLinkComponent;

- (id)initWithCoder:(NSCoder *)aDecoder {
    totalCount++;
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
		self.font = [UIFont systemFontOfSize:8];
        _originalColor = [UIColor colorWithRed:0x2e/255.0 green:0x2e/255.0 blue:0x2e/255.0 alpha:1.0];
		self.textColor = _originalColor;
        self.currentLinkComponent = nil;
		self.currentImgComponent = nil;
        
		//[self setText:@""];
		_textAlignment = RTTextAlignmentLeft;
		_lineBreakMode = RTTextLineBreakModeWordWrapping;
        
		_attrString = NULL;
        _ctFrame = NULL;
        _framesetter = NULL;
        optimumSize = self.frame.size;
        paragraphReplacement = @"\n";
		_thisFont = CTFontCreateWithName ((CFStringRef)[self.font fontName], [self.font pointSize], NULL);
		[self setMultipleTouchEnabled:YES];
    }
    return self;

}


- (id)initWithFrame:(CGRect)_frame {
    totalCount++;
    self = [super initWithFrame:_frame];
    if (self) {
        // Initialization code.
		[self setBackgroundColor:[UIColor clearColor]];
		self.font = [UIFont systemFontOfSize:16];
		_originalColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
		self.textColor = _originalColor;
        self.currentLinkComponent = nil;
		self.currentImgComponent = nil;
       _lineSpacing = 3;
		_textAlignment = RTTextAlignmentLeft;
		_lineBreakMode = RTTextLineBreakModeWordWrapping;
		_attrString = NULL;
        _ctFrame = NULL;
        _framesetter = NULL;
        optimumSize = _frame.size;
        paragraphReplacement = @"\n";
		_thisFont = CTFontCreateWithName ((CFStringRef)[self.font fontName], [self.font pointSize], NULL);
		[self setMultipleTouchEnabled:YES];
    }
    return self;
}
- (void)setFrame:(CGRect)frame {
    if (frame.origin.x == self.frame.origin.y &&
        frame.origin.y == self.frame.origin.y &&
        frame.size.width == self.frame.size.width &&
        frame.size.height == self.frame.size.height) {
         return;
    }
    [super setFrame:frame];
    [self setNeedsDisplay]; 
}


- (void)setTextAlignment:(RTTextAlignment)textAlignment
{
	_textAlignment = textAlignment;
    [self genAttributedString];
	[self setNeedsDisplay];
}

- (RTTextAlignment)textAlignment
{
    return _textAlignment;
}

- (void)setLineBreakMode:(RTTextLineBreakMode)lineBreakMode
{
	_lineBreakMode = lineBreakMode;
    [self genAttributedString];
	[self setNeedsDisplay];
}

- (RTTextLineBreakMode)lineBreakMode
{
    return _lineBreakMode;
}


- (void)setTextColor:(UIColor*)textColor
{
    if (_textColor) {
        if (_textColor != textColor) {
            _textColor = nil;
        }
        else {
            return;
        }
    }
    _textColor = textColor;
    [self genAttributedString];
    [self setNeedsDisplay];
}

- (UIColor*)textColor
{
    return _textColor;
}

- (void)setFont:(UIFont*)font
{
    if (_font) {
        if (_font != font) {
            _font = nil;
        }
        else {
            return;
        }
    }
    _font = font;
    if (_font) {
        if (_thisFont) {
            CFRelease(_thisFont);
        }
        _thisFont = CTFontCreateWithName ((CFStringRef)[self.font fontName], [self.font pointSize], NULL);
    }
}

- (UIFont*)font
{
    return _font;
}
- (void)setComponentsAndPlainText:(RCLabelComponentsStructure*)componnetsDS {
    if (componentsAndPlainText_) {
        if (componentsAndPlainText_ != componnetsDS) {
            componentsAndPlainText_ = nil;
        }
        else {
            return;
        }
    }
    componentsAndPlainText_ = componnetsDS;
    [self genAttributedString];
    [self setNeedsDisplay];
}

- (RCLabelComponentsStructure*)componentsAndPlainText {
    return componentsAndPlainText_;
}

CGSize MyGetSize(void* refCon) {
    NSString *src = (__bridge NSString*)refCon;
    CGSize size = CGSizeMake(100.0,IMAGE_MAX_HEIGHT);
    if (src) {
        if (!imgSizeDict) {
            imgSizeDict = [NSMutableDictionary dictionary];
        }
        NSValue* nsv = [imgSizeDict objectForKey:src];
        if (nsv) {
            [nsv getValue:&size];
            return size;
        }
        UIImage* image = [UIImage imageNamed:src];
        if (image) {
       //     CGSize imageSize = image.size;
     //       CGFloat ratio = imageSize.width / imageSize.height;

//            if (imageSize.width > IMAGE_MAX_WIDTH) {
//                size.width = IMAGE_MAX_WIDTH;
//                size.height = IMAGE_MAX_WIDTH / ratio;
//            }
//            else {
//                size.width = imageSize.width;
//                size.height = imageSize.height;
//            }
            
//            if (size.height > IMAGE_MAX_HEIGHT) {
//                size.height = IMAGE_MAX_HEIGHT;
//                size.width = size.height * ratio;
//            }
//            
//            if (size.height < 1.0) {
//                size.height = 1.0;
//            }
//            if (size.width < 1.0) {
//                size.width = 1.0;
//            }
            size.height=18;
            size.width=18;
            nsv = [NSValue valueWithBytes:&size objCType:@encode(CGSize)];
            [imgSizeDict setObject:nsv forKey:src];
            return size;
        }
    }
    return size;
}

void MyDeallocationCallback( void* refCon ){
    
   
}
CGFloat MyGetAscentCallback( void *refCon ){
    NSString *imgParameter = (__bridge NSString*)refCon;
    
    if (imgParameter) {
        return MyGetSize((__bridge void *)(imgParameter)).height;
    }

    return IMAGE_USER_HEIGHT;
}
CGFloat MyGetDescentCallback( void *refCon ){
    NSString *imgParameter = (__bridge NSString*)refCon;
    if (imgParameter) {
        return 0;
    }
    return IMAGE_USER_DESCENT;
}
CGFloat MyGetWidthCallback( void* refCon ){
    CGSize size = MyGetSize(refCon);
    return size.width;
}

- (void)drawRect:(CGRect)rect 
{
	[self render:YES];
}

- (CGPathRef)newPathForRoundedRect:(CGRect)rect radius:(CGFloat)radius
{
	CGMutablePathRef retPath = CGPathCreateMutable();
	CGRect innerRect = CGRectInset(rect, radius, radius);
	CGFloat inside_right = innerRect.origin.x + innerRect.size.width;
	CGFloat outside_right = rect.origin.x + rect.size.width;
	CGFloat inside_bottom = innerRect.origin.y + innerRect.size.height;
	CGFloat outside_bottom = rect.origin.y + rect.size.height;
	
	CGFloat inside_top = innerRect.origin.y;
	CGFloat outside_top = rect.origin.y;
	CGFloat outside_left = rect.origin.x;
	
	CGPathMoveToPoint(retPath, NULL, innerRect.origin.x, outside_top);
	
	CGPathAddLineToPoint(retPath, NULL, inside_right, outside_top);
	CGPathAddArcToPoint(retPath, NULL, outside_right, outside_top, outside_right, inside_top, radius);
	CGPathAddLineToPoint(retPath, NULL, outside_right, inside_bottom);
	CGPathAddArcToPoint(retPath, NULL,  outside_right, outside_bottom, inside_right, outside_bottom, radius);
	
	CGPathAddLineToPoint(retPath, NULL, innerRect.origin.x, outside_bottom);
	CGPathAddArcToPoint(retPath, NULL,  outside_left, outside_bottom, outside_left, inside_bottom, radius);
	CGPathAddLineToPoint(retPath, NULL, outside_left, inside_top);
	CGPathAddArcToPoint(retPath, NULL,  outside_left, outside_top, innerRect.origin.x, outside_top, radius);
	CGPathCloseSubpath(retPath);
	return retPath;
}

- (CGRect)BoundingRectForLink:(RCLabelComponent*)linkComponent withRun:(CTRunRef)run {
    CGRect runBounds = CGRectZero;
    CFRange runRange = CTRunGetStringRange(run);
    BOOL runStartAfterLink = ((runRange.location >= linkComponent.position) && (runRange.location < linkComponent.position + [linkComponent.text length]));
    BOOL runStartBeforeLink = ((runRange.location < linkComponent.position) && (runRange.location + runRange.length) > linkComponent.position );

    if (runStartAfterLink || runStartBeforeLink) {
        //runRange is within the link range
        CFIndex rangePosition;
        CFIndex rangeLength;
        NSString *linkComponentString;
        if (runStartAfterLink) {
            rangePosition = 0;
            if (linkComponent.position + [linkComponent.text length] > runRange.location + runRange.length) {
                rangeLength = runRange.length;
            }
            else {
                rangeLength = linkComponent.position + [linkComponent.text length] - runRange.location;
            }
            linkComponentString = [self.componentsAndPlainText.plainTextData substringWithRange:NSMakeRange(runRange.location, rangeLength)];
        }
        else {
            rangePosition = linkComponent.position - runRange.location;
            if (linkComponent.position + [linkComponent.text length] > runRange.location + runRange.length) {
                rangeLength = runRange.location + runRange.length - linkComponent.position;
            }
            else {
                rangeLength = [linkComponent.text length];
            }
            linkComponentString = [self.componentsAndPlainText.plainTextData substringWithRange:NSMakeRange(linkComponent.position, rangeLength)];
        }
        if ([[linkComponentString substringToIndex:1] isEqualToString:@"\n"]) {
            rangePosition+=1;
        }
        if ([[linkComponentString substringFromIndex:[linkComponentString length] - 1] isEqualToString:@"\n"]) {
            rangeLength -= 1;
        }
        if (rangeLength <= 0 ) {
            return runBounds;       
        }
        
        CFIndex glyphCount = CTRunGetGlyphCount (run);
        if (rangePosition >= glyphCount) {
            rangePosition = 0;
        }
        if (rangeLength == runRange.length) {
            rangeLength = 0;
        }
        // work out the bounding rect for the glyph run (this doesn't include the origin)
        CGFloat ascent, descent, leading;
        CGFloat width = CTRunGetTypographicBounds(run, CFRangeMake(rangePosition, rangeLength), &ascent, &descent, &leading);
        /*if (![[linkComponentString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] && ascent != MyGetAscentCallback(NULL)) {
            return runBounds;
        }*/
        runBounds.size.width = width;
        runBounds.size.height = ascent + fabsf(descent) + leading+ _lineSpacing;
        
        // get the origin of the glyph run (this is relative to the origin of the line)
        const CGPoint *positions = CTRunGetPositionsPtr(run);
        runBounds.origin.x = positions[rangePosition].x;
        runBounds.origin.y -= ascent;
    }
    return runBounds;
}

- (CGRect)BoundingRectFroImage:(RCLabelComponent*)imgComponent withRun:(CTRunRef)run {
    CGRect runBounds = CGRectZero;
    CFRange runRange = CTRunGetStringRange(run);
    if (runRange.location <= imgComponent.position && runRange.location + runRange.length >= imgComponent.position + [imgComponent.text length]) {
        // work out the bounding rect for the glyph run (this doesn't include the origin)
        NSInteger index = imgComponent.position - runRange.location;
        CGSize imageSize = MyGetSize((__bridge void *)([imgComponent.attributes objectForKey:@"src"]));
        runBounds.size.width = imageSize.width;
        runBounds.size.height = imageSize.height;
        // get the origin of the glyph run (this is relative to the origin of the line)
        const CGPoint *positions = CTRunGetPositionsPtr(run);
        runBounds.origin.x = positions[index].x;
    }
    return runBounds;
}


- (void)render:(BOOL)isYes// isYes这个布尔值是未了区分文件中是否需要设置行距，如果为真则需要设置行距，为否则不需要
{
    if (!self.componentsAndPlainText || !self.componentsAndPlainText.plainTextData) return;
    //context will be nil if we are not in the call stack of drawRect, however we can calculate the height without the context
    CGContextRef context = UIGraphicsGetCurrentContext();
    // Create the framesetter with the attributed string.
    if (_framesetter) {
        CFRelease(_framesetter);
        _framesetter = NULL;
    }
    _framesetter = CTFramesetterCreateWithAttributedString(_attrString);
    // Initialize a rectangular path.
	CGMutablePathRef path = CGPathCreateMutable();
	CGRect bounds = CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height);
	CGPathAddRect(path, NULL, bounds);
	// Create the frame and draw it into the graphics context
    if (_ctFrame) {
        CFRelease(_ctFrame);
        _ctFrame = NULL;
    }
	_ctFrame = CTFramesetterCreateFrame(_framesetter,CFRangeMake(0, 0), path, NULL);
	CFRange range;
	CGSize constraint = CGSizeMake(self.frame.size.width, 1000000);
    CGSize sizeAfterRender = CTFramesetterSuggestFrameSizeWithConstraints(_framesetter, CFRangeMake(0, [self.componentsAndPlainText.plainTextData length]), nil, constraint, &range); 
	self.optimumSize = sizeAfterRender;
    if (context) {
        CFArrayRef lines = CTFrameGetLines(_ctFrame);
        CGPoint lineOrigins[CFArrayGetCount(lines)];
        CTFrameGetLineOrigins(_ctFrame, CFRangeMake(0, 0), lineOrigins);
     
        //Calculate the bounding rect for link
        if (self.currentLinkComponent)
        {
            // get the lines
            CGContextSetTextMatrix(context, CGAffineTransformIdentity);
            CGRect rect = CGPathGetBoundingBox(path);
            // for each line
            for (int i = 0; i < CFArrayGetCount(lines); i++)
            {
                CTLineRef line = CFArrayGetValueAtIndex(lines, i);
                CFArrayRef runs = CTLineGetGlyphRuns(line);
                CGFloat lineAscent;
                CGFloat lineDescent;
                CGFloat lineLeading=10;
                CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, &lineLeading);
                CGPoint origin = lineOrigins[i];
                // fo each glyph run in the line
                for (int j = 0; j < CFArrayGetCount(runs); j++) {
                    CTRunRef run = CFArrayGetValueAtIndex(runs, j);
                    if (!self.currentLinkComponent) {
                        return;
                    }
                    CGRect runBounds = [self BoundingRectForLink:self.currentLinkComponent withRun:run];
                    if (runBounds.size.width != 0 && runBounds.size.height != 0) {
                        //runBounds.size.height = lineAscent + fabsf(lineDescent) + lineLeading;
                        runBounds.origin.x += origin.x;
                        // this is more favourable
                        runBounds.origin.x -= LINK_PADDING;
                        runBounds.size.width += LINK_PADDING * 2;
                        runBounds.origin.y -= LINK_PADDING;
                        runBounds.size.height += LINK_PADDING * 2;
                        CGFloat y = rect.origin.y + rect.size.height - origin.y;
                        runBounds.origin.y += y ;
                        //Adjust the runBounds according to the line original position
                        // Finally, create a rounded rect with a nice shadow and fill.
                        
                        CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
                        CGPathRef highlightPath = [self newPathForRoundedRect:runBounds radius:(0.0)];
                        CGContextSetShadow(context, CGSizeMake(2, 2), 1.0);
                        CGContextAddPath(context, highlightPath);
                        CGContextFillPath(context);
                        CGPathRelease(highlightPath);
                        CGContextSetShadowWithColor(context, CGSizeZero, 0.0, NULL);
                    }
                }
            }
        }
        
            
        CGAffineTransform flipVertical = CGAffineTransformMake(1,0,0,-1,0,self.frame.size.height);
        CGContextConcatCTM(context, flipVertical);
        
        if (isYes) {
            //Calculate the bounding for image
            for (int i = 0; i < CFArrayGetCount(lines); i++) {
                CTLineRef line = CFArrayGetValueAtIndex(lines, i);
                CGFloat lineAscent;
                CGFloat lineDescent;
                CGFloat lineLeading=10;
                CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, &lineLeading);
                CFArrayRef runs = CTLineGetGlyphRuns(line);
                for (int j = 0; j < CFArrayGetCount(runs); j++) {
                    CGFloat ascent;
                    CGFloat descent;
                    CGPoint origin = lineOrigins[i];
                    CTRunRef run = CFArrayGetValueAtIndex(runs, j);
                    NSDictionary* attributes = (NSDictionary*)CTRunGetAttributes(run);
                    CGRect runBounds;
                    runBounds.size.width=CTRunGetTypographicBounds(run, CFRangeMake(0,0), &ascent, &descent, NULL);
                    runBounds=CGRectMake(origin.x+CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL), origin.y-descent, bounds.size.width, ascent+descent);
                    if ([attributes objectForKey:@"imageSrc"])
                    {
                        CGPoint origin = lineOrigins[i];
                        runBounds.origin.x += origin.x;
                        runBounds.origin.y = origin.y;
                        runBounds.origin.y -= 2 * IMAGE_PADDING;
                        NSString *url =  [attributes objectForKey:@"imageSrc"];
                        if ([UIImage imageNamed:url]) {
                            runBounds.size = MyGetSize((__bridge void *)(url));
                            CGContextDrawImage(context, runBounds, [UIImage imageNamed:url].CGImage);
                        }
                        else {
                            CGContextSetFillColorWithColor(context, [[UIColor colorWithRed:(BG_COLOR&0xFF0000>>16)/255.f green:(BG_COLOR&0x00FF00>>8)/255.f blue:(BG_COLOR&0x0000FF)/255.f alpha:1.0f] CGColor]);
                            CGContextFillRect(context, runBounds);
                        }
                    }
                } 
            }
        }
        CTFrameDraw(_ctFrame, context);
    }
    _visibleRange = CTFrameGetVisibleStringRange(_ctFrame);
    
//    if (isYes) {
//        //创建文本对齐方式
//        CTTextAlignment alignment = kCTLeftTextAlignment;//左对齐kCTRightTextAlignment为右对齐
//        CTParagraphStyleSetting alignmentStyle;
//        alignmentStyle.spec=kCTParagraphStyleSpecifierAlignment;//指定为对齐属性
//        alignmentStyle.valueSize=sizeof(alignment);
//        alignmentStyle.value=&alignment;
//        //创建文本行间距
//        CGFloat lineSpace=4.0f;//间距数据
//        CTParagraphStyleSetting lineSpaceStyle;
//        lineSpaceStyle.spec=kCTParagraphStyleSpecifierLineSpacing;//指定为行间距属性
//        lineSpaceStyle.valueSize=sizeof(lineSpace);
//        lineSpaceStyle.value=&lineSpace;
//        //创建样式数组
//        CTParagraphStyleSetting settings[]={
//            alignmentStyle,lineSpaceStyle
//        };
//        //设置样式
//        CTParagraphStyleRef paragraphStyle =CTParagraphStyleCreate(settings, sizeof(settings));
//        //给字符串添加样式attribute
//        [_attrString addAttribute:(id)kCTParagraphStyleAttributeName
//                            value:(id)paragraphStyle
//                            range:NSMakeRange(0,[_attrString  length])];
//    }
	CGPathRelease(path);
}

#pragma mark -
#pragma mark styling

- (void)applyParagraphStyleToText:(CFMutableAttributedStringRef)text attributes:(NSMutableDictionary*)attributes atPosition:(int)position withLength:(int)length
{
	CFMutableDictionaryRef styleDict = ( CFDictionaryCreateMutable( (0), 0, (0), (0) ) );
	// direction
	CTWritingDirection direction = kCTWritingDirectionLeftToRight; 
	// leading
	CGFloat firstLineIndent = 5.0; 
	CGFloat headIndent = 5.0; 
	CGFloat tailIndent = 0.0; 
	CGFloat lineHeightMultiple = 1.0;
	CGFloat maxLineHeight = 0; 
	CGFloat minLineHeight = 0; 
	CGFloat paragraphSpacing = 0.0;
	CGFloat paragraphSpacingBefore = 0.0;
	int textAlignment = _textAlignment;
	int lineBreakMode = _lineBreakMode;
	CGFloat lineSpacing =_lineSpacing;
	
	for (NSString *key in attributes)
	{
		
		id value = [attributes objectForKey:key];
		if ([key isEqualToString:@"align"])
		{
			if ([value isEqualToString:@"left"])
			{
				textAlignment = kCTLeftTextAlignment;
			}
			else if ([value isEqualToString:@"right"])
			{
				textAlignment = kCTRightTextAlignment;
			}
			else if ([value isEqualToString:@"justify"])
			{
				textAlignment = kCTJustifiedTextAlignment;
			}
			else if ([value isEqualToString:@"center"])
			{
				textAlignment = kCTCenterTextAlignment;
			}
		}
		else if ([key isEqualToString:@"indent"])
		{
			firstLineIndent = [value floatValue];
		}
		else if ([key isEqualToString:@"linebreakmode"])
		{
			if ([value isEqualToString:@"wordwrap"])
			{
				lineBreakMode = kCTLineBreakByWordWrapping;
			}
			else if ([value isEqualToString:@"charwrap"])
			{
				lineBreakMode = kCTLineBreakByCharWrapping;
			}
			else if ([value isEqualToString:@"clipping"])
			{
				lineBreakMode = kCTLineBreakByClipping;
			}
			else if ([value isEqualToString:@"truncatinghead"])
			{
				lineBreakMode = kCTLineBreakByTruncatingHead;
			}
			else if ([value isEqualToString:@"truncatingtail"])
			{
				lineBreakMode = kCTLineBreakByTruncatingTail;
			}
			else if ([value isEqualToString:@"truncatingmiddle"])
			{
				lineBreakMode = kCTLineBreakByTruncatingMiddle;
			}
		}
	}
	
	CTParagraphStyleSetting theSettings[] =
	{
		{ kCTParagraphStyleSpecifierAlignment, sizeof(CTTextAlignment), &textAlignment },
		{ kCTParagraphStyleSpecifierLineBreakMode, sizeof(CTLineBreakMode), &lineBreakMode  },
		{ kCTParagraphStyleSpecifierBaseWritingDirection, sizeof(CTWritingDirection), &direction }, 
		{ kCTParagraphStyleSpecifierLineSpacing, sizeof(CGFloat), &lineSpacing },
		{ kCTParagraphStyleSpecifierFirstLineHeadIndent, sizeof(CGFloat), &firstLineIndent }, 
		{ kCTParagraphStyleSpecifierHeadIndent, sizeof(CGFloat), &headIndent }, 
		{ kCTParagraphStyleSpecifierTailIndent, sizeof(CGFloat), &tailIndent }, 
		{ kCTParagraphStyleSpecifierLineHeightMultiple, sizeof(CGFloat), &lineHeightMultiple }, 
		{ kCTParagraphStyleSpecifierMaximumLineHeight, sizeof(CGFloat), &maxLineHeight }, 
		{ kCTParagraphStyleSpecifierMinimumLineHeight, sizeof(CGFloat), &minLineHeight }, 
		{ kCTParagraphStyleSpecifierParagraphSpacing, sizeof(CGFloat), &paragraphSpacing }, 
		{ kCTParagraphStyleSpecifierParagraphSpacingBefore, sizeof(CGFloat), &paragraphSpacingBefore }
	};
	
	CTParagraphStyleRef theParagraphRef = CTParagraphStyleCreate(theSettings, sizeof(theSettings) / sizeof(CTParagraphStyleSetting));
	CFDictionaryAddValue( styleDict, kCTParagraphStyleAttributeName, theParagraphRef );
	CFAttributedStringSetAttributes( text, CFRangeMake(position, length), styleDict, 0 ); 
	CFRelease(theParagraphRef);
    CFRelease(styleDict);
}

- (void)applySingleUnderlineText:(CFMutableAttributedStringRef)text atPosition:(int)position withLength:(int)length
{
    CFStringRef keys[] = { kCTUnderlineStyleAttributeName };
    CFTypeRef values[] = { (__bridge CFNumberRef)[NSNumber numberWithInt:kCTUnderlineStyleSingle] };
    
    CFDictionaryRef fontDict = CFDictionaryCreate(NULL, (const void **)&keys, (const void **)&values, sizeof(keys) / sizeof(keys[0]), NULL, NULL);
    
    CFAttributedStringSetAttributes(text, CFRangeMake(position, length), fontDict, 0);
    CFRelease(fontDict);
}
- (void)applyDoubleUnderlineText:(CFMutableAttributedStringRef)text atPosition:(int)position withLength:(int)length
{
    
    CFStringRef keys[] = { kCTUnderlineStyleAttributeName };
    CFTypeRef values[] = { (__bridge CFNumberRef)[NSNumber numberWithInt:kCTUnderlineStyleDouble] };
    
    CFDictionaryRef fontDict = CFDictionaryCreate(NULL, (const void **)&keys, (const void **)&values, sizeof(keys) / sizeof(keys[0]), NULL, NULL);
    
    CFAttributedStringSetAttributes(text, CFRangeMake(position, length), fontDict, 0);
    CFRelease(fontDict);
}

- (void)applyItalicStyleToText:(CFMutableAttributedStringRef)text atPosition:(int)position withLength:(int)length
{
	UIFont *font = [UIFont italicSystemFontOfSize:self.font.pointSize];
	CTFontRef italicFont = CTFontCreateWithName ((CFStringRef)[font fontName], [font pointSize], NULL); 
    CFStringRef keys[] = { kCTFontAttributeName };
    CFTypeRef values[] = { italicFont };
    CFDictionaryRef fontDict = CFDictionaryCreate(NULL, (const void **)&keys, (const void **)&values, sizeof(keys) / sizeof(keys[0]), NULL, NULL);
    CFAttributedStringSetAttributes(text, CFRangeMake(position, length), fontDict, 0);
	CFRelease(italicFont);
    CFRelease(fontDict);
}

- (void)applyFontAttributes:(NSDictionary*)attributes toText:(CFMutableAttributedStringRef)text atPosition:(int)position withLength:(int)length
{
	for (NSString *key in attributes)
	{
		NSString *value = [attributes objectForKey:key];
		value = [value stringByReplacingOccurrencesOfString:@"'" withString:@""];
		if ([key isEqualToString:@"color"])
		{
			[self applyColor:value toText:text atPosition:position withLength:length];
		}
		else if ([key isEqualToString:@"stroke"])
		{
            
            CFStringRef keys[] = { kCTStrokeWidthAttributeName };
            CFTypeRef values[] = { (__bridge CFTypeRef)([NSNumber numberWithFloat:[[attributes objectForKey:@"stroke"] intValue]]) };
            CFDictionaryRef fontDict = CFDictionaryCreate(NULL, (const void **)&keys, (const void **)&values, sizeof(keys) / sizeof(keys[0]), NULL, NULL);
            CFAttributedStringSetAttributes(text, CFRangeMake(position, length), fontDict, 0);
            CFRelease(fontDict);
		}
		else if ([key isEqualToString:@"kern"])
		{
            CFStringRef keys[] = { kCTKernAttributeName };
            CFTypeRef values[] = { (__bridge CFTypeRef)([NSNumber numberWithFloat:[[attributes objectForKey:@"kern"] intValue]]) };
            
            CFDictionaryRef fontDict = CFDictionaryCreate(NULL, (const void **)&keys, (const void **)&values, sizeof(keys) / sizeof(keys[0]), NULL, NULL);
            CFAttributedStringSetAttributes(text, CFRangeMake(position, length), fontDict, 0);
            CFRelease(fontDict);
		}
		else if ([key isEqualToString:@"underline"])
		{
			int numberOfLines = [value intValue];
			if (numberOfLines==1)
			{
				[self applySingleUnderlineText:text atPosition:position withLength:length];
			}
			else if (numberOfLines==2)
			{
				[self applyDoubleUnderlineText:text atPosition:position withLength:length];
			}
		}
		else if ([key isEqualToString:@"style"])
		{
			if ([value isEqualToString:@"bold"])
			{
				[self applyBoldStyleToText:text atPosition:position withLength:length];
			}
			else if ([value isEqualToString:@"italic"])
			{
				[self applyItalicStyleToText:text atPosition:position withLength:length];
			}
		}
	}
	
	UIFont *font = nil;
	if ([attributes objectForKey:@"face"] && [attributes objectForKey:@"size"])
	{
		NSString *fontName = [attributes objectForKey:@"face"];
		fontName = [fontName stringByReplacingOccurrencesOfString:@"'" withString:@""];
		font = [UIFont fontWithName:fontName size:[[attributes objectForKey:@"size"] intValue]];
	}
	else if ([attributes objectForKey:@"face"] && ![attributes objectForKey:@"size"])
	{
		NSString *fontName = [attributes objectForKey:@"face"];
		fontName = [fontName stringByReplacingOccurrencesOfString:@"'" withString:@""];
		font = [UIFont fontWithName:fontName size:self.font.pointSize];
	}
	else if (![attributes objectForKey:@"face"] && [attributes objectForKey:@"size"])
	{
		font = [UIFont fontWithName:[self.font fontName] size:[[attributes objectForKey:@"size"] intValue]];
	}
	if (font)
	{
		CTFontRef customFont = CTFontCreateWithName ((CFStringRef)[font fontName], [font pointSize], NULL); 
        CFStringRef keys[] = { kCTFontAttributeName };
        CFTypeRef values[] = { customFont };
        CFDictionaryRef fontDict = CFDictionaryCreate(NULL, (const void **)&keys, (const void **)&values, sizeof(keys) / sizeof(keys[0]), NULL, NULL);
        CFAttributedStringSetAttributes(text, CFRangeMake(position, length), fontDict, 0);
		CFRelease(customFont);
        CFRelease(fontDict);
	}
}
//This method will be called when parsing a link
- (void)applyBoldStyleToText:(CFMutableAttributedStringRef)text atPosition:(int)position withLength:(int)length
{
    //If the font size is very large(bigger than 30), core text will invoke a memory
    //warning, and may cause crash.
    UIFont *font = [UIFont boldSystemFontOfSize:self.font.pointSize];
    CTFontRef boldFont = CTFontCreateWithName (CFSTR("Helvetica"), [font pointSize], NULL);
    CFStringRef keys[] = { kCTFontAttributeName };
    CFTypeRef values[] = { boldFont };
    CFDictionaryRef fontDict = CFDictionaryCreate(NULL, (const void **)&keys, (const void **)&values, sizeof(keys) / sizeof(keys[0]), NULL, NULL);
    CFAttributedStringSetAttributes(text, CFRangeMake(position, length), fontDict, 0);
    CFRelease(boldFont);
    CFRelease(fontDict);
}

- (void)applyColor:(NSString*)value toText:(CFMutableAttributedStringRef)text atPosition:(int)position withLength:(int)length
{   
    if(!value) {
		CGColorRef color = [self.textColor CGColor];
        CFStringRef keys[] = { kCTForegroundColorAttributeName };
        CFTypeRef values[] = { color };
        
        CFDictionaryRef colorDict = CFDictionaryCreate(NULL, (const void **)&keys, (const void **)&values, sizeof(keys) / sizeof(keys[0]), NULL, NULL);
        
        CFAttributedStringSetAttributes(text, CFRangeMake(position, length), colorDict, 0);
        CFRelease(colorDict);
    }
	else if ([value rangeOfString:@"#"].location == 0) {
        CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
		value = [value stringByReplacingOccurrencesOfString:@"#" withString:@""];
		NSArray *colorComponents = [self colorForHex:value];
		CGFloat components[] = { [[colorComponents objectAtIndex:0] floatValue] , [[colorComponents objectAtIndex:1] floatValue] , [[colorComponents objectAtIndex:2] floatValue] , [[colorComponents objectAtIndex:3] floatValue] };
        CGColorRef color = CGColorCreate(rgbColorSpace, components);

        CFStringRef keys[] = { kCTForegroundColorAttributeName };
        CFTypeRef values[] = { color };
        
        CFDictionaryRef colorDict = CFDictionaryCreate(NULL, (const void **)&keys, (const void **)&values, sizeof(keys) / sizeof(keys[0]), NULL, NULL);
        
        CFAttributedStringSetAttributes(text, CFRangeMake(position, length), colorDict, 0);
        
		CGColorRelease(color);
        CFRelease(colorDict);
        CGColorSpaceRelease(rgbColorSpace);
	} else {
		value = [value stringByAppendingString:@"Color"];
		SEL colorSel = NSSelectorFromString(value);
		UIColor *_color = nil;
		if ([UIColor respondsToSelector:colorSel]) {
			_color = [UIColor performSelector:colorSel];
			CGColorRef color = [_color CGColor];
            CFStringRef keys[] = { kCTForegroundColorAttributeName };
            CFTypeRef values[] = { color };
            CFDictionaryRef colorDict = CFDictionaryCreate(NULL, (const void **)&keys, (const void **)&values, sizeof(keys) / sizeof(keys[0]), NULL, NULL);
            CFAttributedStringSetAttributes(text, CFRangeMake(position, length), colorDict, 0);
            CFRelease(colorDict);
        }				
	}
}

- (void)applyUnderlineColor:(NSString*)value toText:(CFMutableAttributedStringRef)text atPosition:(int)position withLength:(int)length
{
	value = [value stringByReplacingOccurrencesOfString:@"'" withString:@""];
	if ([value rangeOfString:@"#"].location==0) {
        CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
		value = [value stringByReplacingOccurrencesOfString:@"#" withString:@""];
		NSArray *colorComponents = [self colorForHex:value];
		CGFloat components[] = { [[colorComponents objectAtIndex:0] floatValue] , [[colorComponents objectAtIndex:1] floatValue] , [[colorComponents objectAtIndex:2] floatValue] , [[colorComponents objectAtIndex:3] floatValue] };
		CGColorRef color = CGColorCreate(rgbColorSpace, components);
        CFStringRef keys[] = { kCTUnderlineColorAttributeName };
        CFTypeRef values[] = { color };
        CFDictionaryRef colorDict = CFDictionaryCreate(NULL, (const void **)&keys, (const void **)&values, sizeof(keys) / sizeof(keys[0]), NULL, NULL);
        CFAttributedStringSetAttributes(text, CFRangeMake(position, length), colorDict, 0);
		CGColorRelease(color);
        CFRelease(colorDict);
        CGColorSpaceRelease(rgbColorSpace);
	} else {
		value = [value stringByAppendingString:@"Color"];
		SEL colorSel = NSSelectorFromString(value);
		UIColor *_color = nil;
		if ([UIColor respondsToSelector:colorSel]) {
			_color = [UIColor performSelector:colorSel];
			CGColorRef color = [_color CGColor];
            CFStringRef keys[] = { kCTUnderlineColorAttributeName };
            CFTypeRef values[] = { color };
            CFDictionaryRef colorDict = CFDictionaryCreate(NULL, (const void **)&keys, (const void **)&values, sizeof(keys) / sizeof(keys[0]), NULL, NULL);
            CFAttributedStringSetAttributes(text, CFRangeMake(position, length), colorDict, 0);
            CFRelease(colorDict);    
		}				
	}
}


- (void)applyImageAttributes:(CFMutableAttributedStringRef)text attributes:(NSMutableDictionary*)attributes atPosition:(int)position withLength:(int)length 
{

    // create the delegate
    CTRunDelegateCallbacks callbacks;
    callbacks.version = kCTRunDelegateVersion1;
    callbacks.dealloc = MyDeallocationCallback;
    callbacks.getAscent = MyGetAscentCallback;
    callbacks.getDescent = MyGetDescentCallback;
    callbacks.getWidth = MyGetWidthCallback;
   
    CTRunDelegateRef thedelegate = CTRunDelegateCreate(&callbacks, (__bridge void *)([attributes objectForKey:@"src"]));
    CFStringRef keys[] = { kCTRunDelegateAttributeName ,(CFStringRef)@"imageSrc"};
    CFTypeRef values[] = { thedelegate ,(__bridge CFTypeRef)([attributes objectForKey:@"src"])};
    CFDictionaryRef imgDict = CFDictionaryCreate(NULL, (const void **)&keys, (const void **)&values, sizeof(keys) / sizeof(keys[0]), NULL, NULL);
    CFAttributedStringSetAttributes(text, CFRangeMake(position, length), imgDict, 0);
    CFRelease(thedelegate);
    CFRelease(imgDict);


}

- (void)applyLinkAttributes:(CFMutableAttributedStringRef)text attributes:(NSMutableDictionary*)attributes atPosition:(int)position withLength:(int)length {
    
    [self applyBoldStyleToText:text atPosition:position withLength:length];
    [self applyColor:@"#16387C" toText:text atPosition:position withLength:length];
    
}

- (CGSize)optimumSize:(BOOL)isYes
{
    [self render:isYes];
	return optimumSize;
}


- (void)dealloc 
{
    totalCount--;    
    self.componentsAndPlainText = nil;
    self.textColor = nil;
    self.font = nil;
   // self.text = nil;
    self.paragraphReplacement = nil;
    self.currentLinkComponent = nil;
    self.currentImgComponent = nil;
    
    CFRelease(_thisFont);
    _thisFont = NULL;
    if (_ctFrame) {
        CFRelease(_ctFrame);
        _ctFrame = NULL;
    }
    if (_framesetter) {
        CFRelease(_framesetter);
        _framesetter = NULL;
    }
    if (_attrString) {
        CFRelease(_attrString);
        _attrString = NULL;
    }
}

+ (RCLabelComponentsStructure*)extractTextStyle:(NSString*)text
{
    NSString *plainData = [NSString stringWithString:text];
	NSMutableArray *components = [NSMutableArray array];
    NSMutableArray *linkComponents = [NSMutableArray array];
    NSMutableArray *imgComponents = [NSMutableArray array];
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(http(s)?://([A-Z0-9a-z._-]*(/)?)*)|((@)([A-Z0-9a-z(é|ë|ê|è|à|â|ä|á|ù|ü|û|ú|ì|ï|î|í)-_\u4e00-\u9fa5][^/\\s]+)(:))|((@)([A-Z0-9a-z(é|ë|ê|è|à|â|ä|á|ù|ü|û|ú|ì|ï|î|í)-_\u4e00-\u9fa5]+))|((#)([A-Z0-9a-z(é|ë|ê|è|à|â|ä|á|ù|ü|û|ú|ì|ï|î|í)_\u4e00-\u9fa5]+)(#))|(\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\])" options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSArray *matches = [regex matchesInString:text options:0 range:NSMakeRange(0, [text length])];
    
    //    NSString *tempString = [NSString stringWithString:text];
    NSInteger tempPosition = 0;
    for (NSTextCheckingResult *match in matches) {
        NSRange range = [match range];
        
        NSString *componentText = [text substringWithRange:NSMakeRange(tempPosition, range.location - tempPosition)];
        RCLabelComponent *component = [RCLabelComponent componentWithString:componentText tag:@"rawText" attributes:nil];
        component.isClosure = YES;
        component.position = (int)[plainData rangeOfString:componentText].location;
        [components addObject:component];
        
        NSString *rangeString = [text substringWithRange:range];
        RCLabelComponent *componentSpecial = [RCLabelComponent componentWithString:rangeString tag:@"a" attributes:nil];
        componentSpecial.isClosure = YES;
        componentSpecial.position = (int)[plainData rangeOfString:rangeString].location;
        [components addObject:componentSpecial];
        if ([rangeString hasPrefix:@":"] || [rangeString hasPrefix:@"@"] || [rangeString hasPrefix:@"http" ] || [rangeString hasPrefix:@"#"]) {
            componentSpecial.tagLabel = @"a";
            componentSpecial.attributes = [[NSMutableDictionary alloc] initWithDictionary:@{@"href": componentSpecial.text}] ;
            [linkComponents addObject:componentSpecial];
        }else if ([rangeString hasPrefix:@"["]){
            NSString *filePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"emotionImage.plist"];
            NSDictionary *m_EmojiDic = [[NSDictionary alloc] initWithContentsOfFile:filePath];
            // NSString *path = [NSString stringWithFormat:@"%@", [[NSBundle mainBundle] bundlePath]];
            NSString *i_transCharacter = [m_EmojiDic objectForKey:rangeString];
            if (i_transCharacter) {
                componentSpecial.tagLabel = @"img";
                NSString *tempURL = [RCLabel stripURL:i_transCharacter];
                if (tempURL) {
                    componentSpecial.attributes = [NSMutableDictionary dictionaryWithDictionary:@{@"src": tempURL}];
                    [componentSpecial.attributes setObject:tempURL forKey:@"src"];
                    UIImage  *tempImg = [UIImage imageNamed:tempURL];
                    componentSpecial.img = tempImg;
                    plainData = [plainData stringByReplacingCharactersInRange:NSMakeRange([plainData rangeOfString:rangeString].location, range.length) withString:@"  "];
                    componentSpecial.text = @"\u2000";
                }
                [imgComponents addObject:componentSpecial];
            }
        }
        tempPosition = range.location+range.length;
        
    }
    if (tempPosition < text.length) {
        RCLabelComponent *component = [RCLabelComponent componentWithString:[text substringFromIndex:tempPosition] tag:@"rawText" attributes:nil];
        component.isClosure = YES;
        component.position = (int)tempPosition;
        [components addObject:component];
    }
    RCLabelComponentsStructure *componentsDS = [[RCLabelComponentsStructure alloc] init];
    componentsDS.components = components;
    componentsDS.linkComponents = linkComponents;
    componentsDS.imgComponents = imgComponents;
    componentsDS.plainTextData = plainData;
    return componentsDS;
}

- (void)genAttributedString
{
    if (!self.componentsAndPlainText || !self.componentsAndPlainText.plainTextData || !self.componentsAndPlainText.components) {
        return;
    }
    CFStringRef string = (__bridge CFStringRef)self.componentsAndPlainText.plainTextData;
	if (_attrString) {
        CFRelease(_attrString);
        _attrString = NULL;
    }
    _attrString = CFAttributedStringCreateMutable(NULL, 0);
    
    CFAttributedStringReplaceString (_attrString, CFRangeMake(0, 0), string);
	CFMutableDictionaryRef styleDict = CFDictionaryCreateMutable(NULL, 0, 0, 0);
	CFDictionaryAddValue( styleDict, kCTForegroundColorAttributeName, [self.textColor CGColor] );
	CFAttributedStringSetAttributes( _attrString, CFRangeMake( 0, CFAttributedStringGetLength(_attrString) ), styleDict, 0 ); 
	[self applyParagraphStyleToText:_attrString attributes:nil atPosition:0 withLength:(int)CFAttributedStringGetLength(_attrString)];
    CFStringRef keys[] = { kCTFontAttributeName };
    CFTypeRef values[] = { _thisFont };
    
    CFDictionaryRef fontDict = CFDictionaryCreate(NULL, (const void **)&keys, (const void **)&values, sizeof(keys) / sizeof(keys[0]), NULL, NULL);
    CFAttributedStringSetAttributes(_attrString, CFRangeMake(0, CFAttributedStringGetLength(_attrString)), fontDict, 0);
    CFRelease(fontDict); 

	for (RCLabelComponent *component in self.componentsAndPlainText.components)
	{
		int index = (int)[self.componentsAndPlainText.components indexOfObject:component];
		component.componentIndex = index;
		if ([component.tagLabel isEqualToString:@"i"])
		{
			// make font italic
			[self applyItalicStyleToText:_attrString atPosition:component.position withLength:(int)[component.text length]];
            [self applyColor:nil toText:_attrString atPosition:component.position withLength:(int)[component.text length]];
         //   [self applyColor:@"#2e2e2e" toText:_attrString atPosition:component.position withLength:[component.text length]];
		}
		else if ([component.tagLabel isEqualToString:@"b"])
		{
			// make font bold
			[self applyBoldStyleToText:_attrString atPosition:component.position withLength:(int)[component.text length]];
            [self applyColor:nil toText:_attrString atPosition:component.position withLength:(int)[component.text length]];
           // [self applyColor:@"#2e2e2e" toText:_attrString atPosition:component.position withLength:[component.text length]];
		}
		else if ([component.tagLabel isEqualToString:@"a"])
		{
            NSString *value = [component.attributes objectForKey:@"href"];
            if (!value) {
                [component.attributes setObject:@"" forKey:@"href"];
            }
            [self applyLinkAttributes:_attrString attributes:component.attributes atPosition:component.position withLength:(int)[component.text length]];
        }
		else if ([component.tagLabel isEqualToString:@"u"] || [component.tagLabel isEqualToString:@"underlined"])
		{
			// underline
			if ([component.tagLabel isEqualToString:@"u"])
			{
				[self applySingleUnderlineText:_attrString atPosition:component.position withLength:(int)[component.text length]];
			}
			if ([component.attributes objectForKey:@"color"])
			{
				NSString *value = [component.attributes objectForKey:@"color"];
				[self applyUnderlineColor:value toText:_attrString atPosition:component.position withLength:(int)[component.text length]];
			}
		}
		else if ([component.tagLabel isEqualToString:@"font"])
		{
			[self applyFontAttributes:component.attributes toText:_attrString atPosition:component.position withLength:(int)[component.text length]];
		}
		else if ([component.tagLabel isEqualToString:@"p"])
		{
			[self applyParagraphStyleToText:_attrString attributes:component.attributes atPosition:component.position withLength:(int)[component.text length]];
		}
        else if([component.tagLabel isEqualToString:@"img"])
        {
            [self applyImageAttributes:_attrString attributes:component.attributes atPosition:component.position withLength:(int)[component.text length]];
        }
	}
    CFRelease(styleDict);
}

- (NSArray*)colorForHex:(NSString *)hexColor
{
	hexColor = [[hexColor stringByTrimmingCharactersInSet:
				 [NSCharacterSet whitespaceAndNewlineCharacterSet]
				 ] uppercaseString];  

    NSRange range;  
    range.location = 0;  
    range.length = 2; 
	
    NSString *rString = [hexColor substringWithRange:range];  
    range.location = 2;  
    NSString *gString = [hexColor substringWithRange:range];  
    range.location = 4;  
    NSString *bString = [hexColor substringWithRange:range];  
	
    // Scan values  
    unsigned int r, g, b;  
    [[NSScanner scannerWithString:rString] scanHexInt:&r];  
    [[NSScanner scannerWithString:gString] scanHexInt:&g];  
    [[NSScanner scannerWithString:bString] scanHexInt:&b];  
	
	NSArray *components = [NSArray arrayWithObjects:[NSNumber numberWithFloat:((float) 27.0 / 255.0f)],[NSNumber numberWithFloat:((float) 116.0 / 255.0f)],[NSNumber numberWithFloat:((float) 174.0 / 255.0f)],[NSNumber numberWithFloat:1.0],nil];
	return components;
	
}

//Remove the space and quotation
+ (NSString*)stripURL:(NSString*)url {
   return [[url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\\\'\""]];
}


#pragma mark -
#pragma mark Touch Handling


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView:self];
	
	CFArrayRef lines = CTFrameGetLines(_ctFrame);
	CGPoint origins[CFArrayGetCount(lines)];
	CTFrameGetLineOrigins(_ctFrame, CFRangeMake(0, 0), origins);
	
	CTLineRef line = NULL;
	CGPoint lineOrigin = CGPointZero;
    CGPathRef path = CTFrameGetPath(_ctFrame);
    CGRect rect = CGPathGetBoundingBox(path);
    CGFloat nextLineY = 0;
	for (int i= 0; i < CFArrayGetCount(lines); i++)
	{
		CGPoint origin = origins[i];
		
		CGFloat y = rect.origin.y + rect.size.height - origin.y;
        CTLineRef tempLine = CFArrayGetValueAtIndex(lines, i);
        CGFloat ascend = 0;
        CGFloat decend = 0;
        CGFloat leading = 0;
        CTLineGetTypographicBounds(tempLine, &ascend, &decend, &leading);
        y -= ascend;
        
		if ((location.y >= y) && (location.x >= origin.x))
		{
            
			line = CFArrayGetValueAtIndex(lines, i);
			lineOrigin = origin;
		}
        nextLineY = y + ascend + fabsf(decend) + leading;
	}
	if (!line || location.y >= nextLineY) {
        return;
    }
	location.x -= lineOrigin.x;
    
    CFArrayRef runs = CTLineGetGlyphRuns(line);
    CGFloat lineAscent;
    CGFloat lineDescent;
    CGFloat lineLeading;
    CTRunRef run = nil;
    CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, &lineLeading);
    BOOL isClicked = NO;
    for (int j = 0; j < CFArrayGetCount(runs); j++) {
        run = CFArrayGetValueAtIndex(runs, j);
        
        CGFloat ascent, descent, leading;
    
        CGFloat width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, &leading);
        
        const CGPoint *positions = CTRunGetPositionsPtr(run);
        
        
        if (location.x <= width + positions[0].x) {
            isClicked = YES;
            break;
        } 
       
    }
    if (!isClicked) {
        [super touchesBegan:touches withEvent:event];
        return;
    }
    CFRange runRange = CTRunGetStringRange(run);
	RCLabelComponent *tempComponent = nil;
	for (RCLabelComponent *component in self.componentsAndPlainText.linkComponents)
	{
        BOOL runStartAfterLink = ((runRange.location >= component.position) && (runRange.location < component.position + component.text.length));
        BOOL runStartBeforeLink = ((runRange.location < component.position) && (runRange.location + runRange.length) > component.position );
        if (runStartAfterLink || runStartBeforeLink) {
            tempComponent = component;
        }
        
      
	}
    if (tempComponent) {
        self.currentLinkComponent = tempComponent;
        [self setNeedsDisplay];
    }
    else {
        for (RCLabelComponent *component in self.componentsAndPlainText.imgComponents)
        {
            BOOL runStartAfterLink = ((runRange.location >= component.position) && (runRange.location < component.position + component.text.length));
            BOOL runStartBeforeLink = ((runRange.location < component.position) && (runRange.location + runRange.length) > component.position );
            if (runStartAfterLink || runStartBeforeLink) {
                tempComponent = component;
            }
        }
        if (tempComponent) {
            self.currentImgComponent = tempComponent;
            [self setNeedsDisplay];
        }
        else {
            [super touchesBegan:touches withEvent:event];
        }
        
    }
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{	
    [super touchesMoved:touches withEvent:event];
    [self dismissBoundRectForTouch];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    [self dismissBoundRectForTouch];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{	
    [super touchesEnded:touches withEvent:event];
    if (self.currentLinkComponent) {
        if ([delegate respondsToSelector:@selector(RCLabel:didSelectLinkWithURL:)]) {
            [delegate RCLabel:self didSelectLinkWithURL:[self.currentLinkComponent.attributes objectForKey:@"href"]];
        }
        
    }
    else if(self.currentImgComponent) {
        if ([delegate respondsToSelector:@selector(RCLabel:didSelectLinkWithURL:)]) {
            [delegate RCLabel:self didSelectLinkWithURL:[self.currentImgComponent.attributes objectForKey:@"src"]];
        }
    }
    [self performSelector:@selector(dismissBoundRectForTouch) withObject:nil afterDelay:0.1];
}
- (void)dismissBoundRectForTouch
{
    self.currentImgComponent = nil;
    self.currentLinkComponent = nil;
    [self setNeedsDisplay]; 
}


- (NSString*)visibleText
{
    [self render:YES];
    NSString *text = [self.componentsAndPlainText.plainTextData substringWithRange:NSMakeRange(_visibleRange.location, _visibleRange.length)];
    return text;
}

@end
