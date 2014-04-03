//
//  FHTweetLabel.m
//  Weirdo
//
//  Created by FengHuan on 14-4-2.
//  Copyright (c) 2014年 FengHuan. All rights reserved.
//

#import "FHTweetLabel.h"

#define colorRangeIsHashtag @"1"
#define colorRangeIsLink @"2"

@implementation FHTweetLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        [self setUserInteractionEnabled:YES];
        [self setNumberOfLines:0];
        
        colorHashtag = [UIColor colorWithWhite:170.0/255.0 alpha:1.0];
        colorLink = [UIColor colorWithRed:129.0/255.0 green:171.0/255.0 blue:193.0/255.0 alpha:1.0];
        colorRanges = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

+ (CGSize)sizeOfText:(NSString *)text withFont:(UIFont *)font constarintToWidth:(float)width
{
    CGSize size;
    NSDictionary *words = [FHTweetLabel wordRangesOfText:text];
    float constaintWidth = width;
    float singleLineHeight = 0.0;
    float contentWidth = 0.0;
    float contentHeight = 0.0;
    
    NSArray *wordLocations;
    if (words && words.count >0) {
        wordLocations = [words allKeys];
    }
    for (int i=0; i<text.length; i++)
    {
        NSString *singleChar = [text substringWithRange:NSMakeRange(i, 1)];
        CGSize charSize = [singleChar sizeWithFont:font];
        float adjustCharWidth = charSize.width - 1;
        if (i == 0) {
            contentHeight = charSize.height;
            singleLineHeight = charSize.height;
        }
        
        if ([singleChar rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet] options:NSBackwardsSearch].location != NSNotFound) {
            contentWidth = adjustCharWidth;
            contentHeight = contentHeight + charSize.height;
        }else if ([wordLocations containsObject:[NSString stringWithFormat:@"%d",i]]) {
            NSRange wordRange = NSMakeRange(i, [[words objectForKey:[NSString stringWithFormat:@"%d",i]] integerValue]);
            CGSize wordSize = [[text substringWithRange:wordRange] sizeWithFont:font];
            float adjustWordWidth = wordSize.width - 1;
            if (contentWidth + adjustWordWidth > constaintWidth) {
                contentWidth = adjustCharWidth;
                contentHeight = contentHeight + wordSize.height;
            }
        }else{
            if (contentWidth + adjustCharWidth > constaintWidth) {
                contentWidth = adjustCharWidth;
                contentHeight = contentHeight + charSize.height;
            }else{
                contentWidth = contentWidth + adjustCharWidth;
            }
        }
    }
    
    if (contentHeight > singleLineHeight) {
        size = CGSizeMake(constaintWidth, contentHeight);
    }else{
        size = CGSizeMake(contentWidth, contentHeight);
    }
    return size;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize theSize = [FHTweetLabel sizeOfText:self.text withFont:self.font constarintToWidth:size.width];
    return theSize;
}

- (void)drawTextInRect:(CGRect)rect
{
    CGPoint drawPoint = CGPointMake(0.0, 0.0);
    NSDictionary *wordRanges = [FHTweetLabel wordRangesOfText:self.text];
    NSArray *wordLocations = [wordRanges allKeys];
    
    for (int i=0; i<self.text.length; i++)
    {
        
        NSString *singleChar = [self.text substringWithRange:NSMakeRange(i, 1)];
        CGSize sizeChar = [singleChar sizeWithFont:self.font];
        CGSize adjustedSizeChar = CGSizeMake(sizeChar.width-1, sizeChar.height);
        
        if ([singleChar rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet] options:NSBackwardsSearch].location != NSNotFound) {
            drawPoint = CGPointMake(0, drawPoint.y+adjustedSizeChar.height);
            
        }else if ([wordLocations containsObject:[NSString stringWithFormat:@"%d",i]]) {
            NSRange wordRange = NSMakeRange(i, [[wordRanges objectForKey:[NSString stringWithFormat:@"%d",i]] integerValue]);
            CGSize wordSize = [[self.text substringWithRange:wordRange] sizeWithFont:self.font];
            float adjustWordWidth = wordSize.width - 1;
            if (drawPoint.x + adjustWordWidth > rect.size.width) {
                drawPoint = CGPointMake(0, drawPoint.y+wordSize.height);
            }
        }else{
            if (drawPoint.x + adjustedSizeChar.width > rect.size.width) {
                drawPoint = CGPointMake(0, drawPoint.y + adjustedSizeChar.height);
            }
        }
        [singleChar drawAtPoint:drawPoint withFont:self.font];

        drawPoint = CGPointMake(drawPoint.x + adjustedSizeChar.width, drawPoint.y);
    }
}

+ (NSDictionary *)wordRangesOfText:(NSString *)text
{
    text = [FHTweetLabel htmlToText:text];
    NSMutableDictionary *wordRangesDic = [[NSMutableDictionary alloc] init];
    if (!text) {
        return wordRangesDic;
    }
    NSError *error;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(http(s)?://([A-Z0-9a-z._-]*(/)?)*)|((@)([A-Z0-9a-z(é|ë|ê|è|à|â|ä|á|ù|ü|û|ú|ì|ï|î|í)-_\u4e00-\u9fa5][^/\\s]+)(:))|((@)([A-Z0-9a-z(é|ë|ê|è|à|â|ä|á|ù|ü|û|ú|ì|ï|î|í)-_\u4e00-\u9fa5]+))|((#)([A-Z0-9a-z(é|ë|ê|è|à|â|ä|á|ù|ü|û|ú|ì|ï|î|í)_\u4e00-\u9fa5]+)(#))|([A-Za-z0-9]+)" options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSArray *matches = [regex matchesInString:text options:0 range:NSMakeRange(0, [text length])];
    
    for (NSTextCheckingResult *match in matches) {
        NSRange range = [match range];
        NSString *rangeString = [text substringWithRange:range];
        if ([rangeString hasSuffix:@":"]) {
            rangeString = [rangeString substringToIndex:rangeString.length-1];
            //            DLog(@"@String{%d} %@",rangeString.length, rangeString);
        }else if ([rangeString hasPrefix:@"@"]) {
            //            DLog(@"@String{%d} %@",rangeString.length, rangeString);
        }else if ([rangeString hasPrefix:@"http"]){
            //            DLog(@"httpString{%d} %@",rangeString.length, rangeString);
        }else if([rangeString hasPrefix:@"#"]){
            //
        }else{
            [wordRangesDic setObject:[NSString stringWithFormat:@"%d",range.length] forKey:[NSString stringWithFormat:@"%d",range.location]];
        }
    }
    return wordRangesDic;
}

+ (NSString *)htmlToText:(NSString *)htmlString
{
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"&amp;"  withString:@"&"];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"&lt;"  withString:@"<"];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"&gt;"  withString:@">"];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"&quot;" withString:@""""];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"&#039;"  withString:@"'"];
    
    return htmlString;
}

@end
