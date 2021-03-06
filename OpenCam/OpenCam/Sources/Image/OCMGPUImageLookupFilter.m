//
//  OCMGPUImageLookupFilter.m
//  OpenCam
//
//  Created by Jason Hsu on 2013/12/12.
//  Copyright (c) 2013年 Jason Hsu. All rights reserved.
//

#import "OCMGPUImageLookupFilter.h"


NSString *const kOCMGPUImageLookupFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2; // TODO: This is not used
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2; // lookup texture
 
 uniform highp float level; // 0 ~ 1
 
 void main()
 {
     highp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     
     highp float blueColor = textureColor.b * 63.0;
     
     highp vec2 quad1;
     quad1.y = floor(floor(blueColor) / 8.0);
     quad1.x = floor(blueColor) - (quad1.y * 8.0);
     
     highp vec2 quad2;
     quad2.y = floor(ceil(blueColor) / 8.0);
     quad2.x = ceil(blueColor) - (quad2.y * 8.0);
     
     highp vec2 texPos1;
     texPos1.x = (quad1.x * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * textureColor.r);
     texPos1.y = (quad1.y * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * textureColor.g);
     
     highp vec2 texPos2;
     texPos2.x = (quad2.x * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * textureColor.r);
     texPos2.y = (quad2.y * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * textureColor.g);
     
     lowp vec4 newColor1 = texture2D(inputImageTexture2, texPos1);
     lowp vec4 newColor2 = texture2D(inputImageTexture2, texPos2);
     
     lowp vec4 newColor = mix(newColor1, newColor2, fract(blueColor));
     
     lowp vec4 c = mix(textureColor, newColor, level);
     
     gl_FragColor = vec4(c.rgb, textureColor.w);
 }
 );


@implementation OCMGPUImageLookupFilter

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kOCMGPUImageLookupFragmentShaderString]))
    {
		return nil;
    }
    
    levelUniform = [filterProgram uniformIndex:@"level"];
    self.level = 1.0;
	
    return self;
}

- (CGFloat)level
{
    return _level;
}

- (void)setLevel:(CGFloat)level
{
    _level = level;
    
    [self setFloat:_level forUniform:levelUniform program:filterProgram];
}

@end