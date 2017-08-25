//
//  CRExifDict.m
//  FinalWebP
//
//  Created by Courser on 23/08/2017.
//  Copyright © 2017 Courser. All rights reserved.
//

#import "CRExifDict.h"
#import "CRTag.h"

@implementation CRExifDict

- (instancetype)init {
    if (self = [super init]) {
        _tagDict = [NSDictionary dictionaryWithObjectsAndKeys:
                    @"ImageDescription",ImageDescription,
                    @"Make",Make,
                    @"Model",Model,
                    @"Orientation",Orientation,
                    @"XResolution",XResolution,
                    @"YResolution",YResolution,
                    @"ResolutionUnit",ResolutionUnit,
                    @"Software",Software,
                    @"DateTime",DateTime,
                    @"WhitePoint",WhitePoint,
                    @"PrimaryChromaticities",PrimaryChromaticities,
                    @"YCbCrCoefficients",YCbCrCoefficients,
                    @"YCbCrPositioning",YCbCrPositioning,
                    @"ReferenceBlackWhite",ReferenceBlackWhite,
                    @"Copyright",Copyright,
                    @"ExifOffset",ExifOffset
                    , nil];
        
        _nextDict = [NSDictionary dictionaryWithObjectsAndKeys:
                     @"IFD1ImageWidth",IFD1ImageWidth,
                     @"IFD1ImageLength",IFD1ImageLength,
                     @"IFD1BitsPerSample",IFD1BitsPerSample,
                     @"IFD1Compression",IFD1Compression,
                     @"IFD1PhotometricInterpretation",IFD1PhotometricInterpretation,
                     @"IFD1StripOffsets",IFD1StripOffsets,
                     @"IFD1SamplesPerPixel",IFD1SamplesPerPixel,
                     @"IFD1RowsPerStrip",IFD1RowsPerStrip,
                     @"IFD1StripByteConunts",IFD1StripByteConunts,
                     @"IFD1XResolution",IFD1XResolution,
                     @"IFD1YResolution",IFD1YResolution,
                     @"IFD1PlanarConfiguration",IFD1PlanarConfiguration,
                     @"IFD1ResolutionUnit",IFD1ResolutionUnit,
                     @"IFD1JpegIFOffset",IFD1JpegIFOffset,
                     @"IFD1JpegIFByteCount",IFD1JpegIFByteCount,
                     @"IFD1YCbCrSubSampling",IFD1YCbCrSubSampling,
                     @"IFD1YCbCrPositioning",IFD1YCbCrPositioning,
                     @"IFD1ReferenceBlackWhite",IFD1ReferenceBlackWhite
                     , nil];
        
        _typeDict = [NSDictionary dictionaryWithObjectsAndKeys:
                     @(1),@"1",
                     @(1),@"2",
                     @(2),@"3",
                     @(4),@"4",
                     @(8),@"5",
                     @(1),@"6",
                     @(1),@"7",
                     @(2),@"8",
                     @(4),@"9",
                     @(8),@"10",
                     @(4),@"11",
                     @(8),@"12"
                     , nil];
        
        _childDict = [NSDictionary dictionaryWithObjectsAndKeys:
                      @"ExposureTime",ExposureTime,
                      @"FNumber",FNumber,
                      @"ExposureProgram",ExposureProgram,
                      @"ISOSpeedRatings",ISOSpeedRatings,
                      @"ExifVersion",ExifVersion,
                      @"DateTimeOriginal",DateTimeOriginal,
                      @"DateTimeDigitized",DateTimeDigitized,
                      @"ComponentsConfiguration",ComponentsConfiguration,
                      @"CompressedBitsPerPixel",CompressedBitsPerPixel,
                      @"ShutterSpeedValue",ShutterSpeedValue,
                      @"ApertureValue",ApertureValue,
                      @"BrightnessValue",BrightnessValue,
                      @"ExposureBiasValue",ExposureBiasValue,
                      @"MaxApertureValue",MaxApertureValue,
                      @"SubjectDistance",SubjectDistance,
                      @"MeteringMode",MeteringMode,
                      @"LightSource",LightSource,
                      @"Flash",Flash,
                      @"FocalLength",FocalLength,
                      @"MakerNote",MakerNote,
                      @"UserComment",UserComment,
                      @"SubsecTime",SubsecTime,
                      @"SubsecTimeOriginal",SubsecTimeOriginal,
                      @"SubsecTimeDigitized",SubsecTimeDigitized,
                      @"FlashPixVersion",FlashPixVersion,
                      @"ColorSpace",ColorSpace,
                      @"ExifImageWidth",ExifImageWidth,
                      @"ExifImageHeight",ExifImageHeight,
                      @"RelatedSoundFile",RelatedSoundFile,
                      @"ExifInteroperabilityOffset",ExifInteroperabilityOffset,
                      @"FocalPlaneXResolution",FocalPlaneXResolution,
                      @"FocalPlaneYResolution",FocalPlaneYResolution,
                      @"FocalPlaneResolutionUnit",FocalPlaneResolutionUnit,
                      @"ExposureIndex",ExposureIndex,
                      @"SensingMethod",SensingMethod,
                      @"FileSource",FileSource,
                      @"SceneType",SceneType,
                      @"CFAPattern",CFAPattern
                      , nil];
    }
    return self;
}

@end
