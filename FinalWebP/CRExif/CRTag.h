//
//  CRTag.h
//  FinalWebP
//
//  Created by Courser on 23/08/2017.
//  Copyright © 2017 Courser. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef CRTag_h
#define CRTag_h

// IFD0主图像标签
NSString *ImageDescription = @"010e";
NSString *Make = @"010f";
NSString *Model = @"0110";
NSString *Orientation = @"0112";
NSString *XResolution = @"011a";
NSString *YResolution = @"011b";
NSString *ResolutionUnit = @"0128";
NSString *Software = @"0131";
NSString *DateTime = @"0132";
NSString *WhitePoint = @"013e";
NSString *PrimaryChromaticities = @"013f";
NSString *YCbCrCoefficients = @"0211";
NSString *YCbCrPositioning = @"0213";
NSString *ReferenceBlackWhite = @"0214";
NSString *Copyright = @"8298";
NSString *ExifOffset = @"8769";

// 子IFD使用的标签
NSString *ExposureTime = @"829a";
NSString *FNumber = @"829d";
NSString *ExposureProgram = @"8822";
NSString *ISOSpeedRatings = @"8827";
NSString *ExifVersion = @"9000";
NSString *DateTimeOriginal = @"9003";
NSString *DateTimeDigitized = @"9004";
NSString *ComponentsConfiguration = @"9101";
NSString *CompressedBitsPerPixel = @"9102";
NSString *ShutterSpeedValue = @"9201";
NSString *ApertureValue = @"9202";
NSString *BrightnessValue = @"9203";
NSString *ExposureBiasValue = @"9204";
NSString *MaxApertureValue = @"9205";
NSString *SubjectDistance = @"9206";
NSString *MeteringMode = @"9207";
NSString *LightSource = @"9208";
NSString *Flash = @"9209";
NSString *FocalLength = @"920a";
NSString *MakerNote = @"927c";
NSString *UserComment = @"9286";
NSString *SubsecTime = @"9290";
NSString *SubsecTimeOriginal = @"9291";
NSString *SubsecTimeDigitized = @"9292";
NSString *FlashPixVersion = @"a000";
NSString *ColorSpace = @"a001";
NSString *ExifImageWidth = @"a002";
NSString *ExifImageHeight = @"a003";
NSString *RelatedSoundFile = @"a004";
NSString *ExifInteroperabilityOffset = @"a005";
NSString *FocalPlaneXResolution = @"a20e";
NSString *FocalPlaneYResolution = @"a20f";
NSString *FocalPlaneResolutionUnit = @"a210";
NSString *ExposureIndex = @"a215";
NSString *SensingMethod = @"a217";
NSString *FileSource = @"a300";
NSString *SceneType = @"a301";
NSString *CFAPattern = @"a302";

// IFD1 (缩略图)使用的标签
NSString *IFD1ImageWidth = @"0100";
NSString *IFD1ImageLength = @"0101";
NSString *IFD1BitsPerSample = @"0102";
NSString *IFD1Compression = @"0103";
NSString *IFD1PhotometricInterpretation = @"0106";
NSString *IFD1StripOffsets = @"0111";
NSString *IFD1SamplesPerPixel = @"0115";
NSString *IFD1RowsPerStrip = @"0116";
NSString *IFD1StripByteConunts = @"0117";
NSString *IFD1XResolution = @"011a";
NSString *IFD1YResolution = @"011b";
NSString *IFD1PlanarConfiguration = @"011c";
NSString *IFD1ResolutionUnit = @"0128";
NSString *IFD1JpegIFOffset = @"0201";
NSString *IFD1JpegIFByteCount = @"0202";
NSString *IFD1YCbCrSubSampling = @"0212";
NSString *IFD1YCbCrPositioning = @"0213";
NSString *IFD1ReferenceBlackWhite = @"0214";

#endif /* CRTag_h */
