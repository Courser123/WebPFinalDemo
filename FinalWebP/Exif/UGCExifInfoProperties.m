//
//  XLExifInfoProperties.m
//  ExifDemo
//
//  Created by 薛琳 on 16/4/23.
//  Copyright © 2016年 Welson. All rights reserved.
//
#import "UGCExifInfoProperties.h"

//IFD0 (主图像)使用的标签
NSString *kImageDescription = @"010e";
NSString *kMake = @"010f";
NSString *kModel = @"0110";
NSString *kOrientation = @"0112";
NSString *kXResolution = @"011a";
NSString *kYResolution = @"011b";
NSString *kResolutionUnit = @"0128";
NSString *kSoftware = @"0131";
NSString *kDateTime = @"0132";
NSString *kWhitePoint = @"013e";
NSString *kPrimaryChromaticities = @"013f";
NSString *kYCbCrCoefficients = @"0211";
NSString *kYCbCrPositioning = @"0213";
NSString *kReferenceBlackWhite = @"0214";
NSString *kCopyright = @"8298";
NSString *kExifOffset = @"8769";

//Exif 子IFD使用的标签
NSString *kExposureTime = @"829a";
NSString *kFNumber = @"829d";
NSString *kExposureProgram = @"8822";
NSString *kISOSpeedRatings = @"8827";
NSString *kExifVersion = @"9000";
NSString *kDateTimeOriginal = @"9003";
NSString *kDateTimeDigitized = @"9004";
NSString *kComponentsConfiguration = @"9101";
NSString *kCompressedBitsPerPixel = @"9102";
NSString *kShutterSpeedValue = @"9201";
NSString *kApertureValue = @"9202";
NSString *kBrightnessValue = @"9203";
NSString *kExposureBiasValue = @"9204";
NSString *kMaxApertureValue = @"9205";
NSString *kSubjectDistance = @"9206";
NSString *kMeteringMode = @"9207";
NSString *kLightSource = @"9208";
NSString *kFlash = @"9209";
NSString *kFocalLength = @"920a";
NSString *kMakerNote = @"927c";
NSString *kUserComment = @"9286";
NSString *kSubsecTime = @"9290";
NSString *kSubsecTimeOriginal = @"9291";
NSString *kSubsecTimeDigitized = @"9292";
NSString *kFlashPixVersion = @"a000";
NSString *kColorSpace = @"a001";
NSString *kExifImageWidth = @"a002";
NSString *kExifImageHeight = @"a003";
NSString *kRelatedSoundFile = @"a004";
NSString *kExifInteroperabilityOffset = @"a005";
NSString *kFocalPlaneXResolution = @"a20e";
NSString *kFocalPlaneYResolution = @"a20f";
NSString *kFocalPlaneResolutionUnit = @"a210";
NSString *kExposureIndex = @"a215";
NSString *kSensingMethod = @"a217";
NSString *kFileSource = @"a300";
NSString *kSceneType = @"a301";
NSString *kCFAPattern = @"a302";

//Interoperability IFD
NSString *kInteroperabilityIndex = @"0001";
NSString *kInteroperabilityVersion = @"0002";
NSString *kRelatedImageFileFormat = @"1000";
NSString *kRelatedImageWidth = @"1001";

//IFD1 (缩略图)使用的标签
NSString *kImageWidth = @"0100";
NSString *kImageLength = @"0101";
NSString *kBitsPerSample = @"0102";
NSString *kCompression = @"0103";
NSString *kPhotometricInterpretation = @"0106";
NSString *kStripOffsets = @"0111";
NSString *kSamplesPerPixel = @"0115";
NSString *kRowsPerStrip = @"0116";
NSString *kStripByteConunts = @"0117";
NSString *kPlanarConfiguration = @"011c";
NSString *kJpegIFOffset = @"0201";
NSString *kJpegIFByteCount = @"0202";
NSString *kYCbCrSubSampling = @"0212";

//Misc Tags
NSString *kNewSubfileType = @"00fe";
NSString *kSubfileType = @"00ff";
NSString *kTransferFunction = @"012d";
NSString *kArtist = @"013b";
NSString *kPredictor = @"013d";
NSString *kTileWidth = @"0142";
NSString *kTileLength = @"0143";
NSString *kTileOffsets = @"0144";
NSString *kTileByteCounts = @"0145";
NSString *kSubIFDs = @"014a";
NSString *kJPEGTables = @"015b";
NSString *kCFARepeatPatternDim = @"828d";
NSString *kCFAPatternMisc = @"828e";
NSString *kBatteryLevel = @"828f";
NSString *kInterColorProfile = @"8773";
NSString *kSpectralSensitivity = @"8824";
NSString *kGPSInfo = @"8825";
NSString *kOECF = @"8828";
NSString *kInterlace = @"8829";
NSString *kTimeZoneOffset = @"882a";
NSString *kSelfTimerMode = @"882b";
NSString *kFlashEnergy = @"920b";
NSString *kSpatialFrequencyResponse = @"920c";
NSString *kNoise = @"920d";
NSString *kImageNumber = @"9211";
NSString *kSecurityClassification = @"9212";
NSString *kImageHistory = @"9213";
NSString *kSubjectLocation = @"9214";
NSString *kExposureIndexMisc = @"9215";
NSString *kFlashEnergyMisc = @"a20b";
NSString *kSpatialFrequencyResponseMisc = @"a20c";
NSString *kSubjectLocationMisc = @"a214";

NSString *kExifEndFlag = @"0000";
NSString *kExifStartFlag = @"002a";
NSString *kExifTypeIntel = @"4949";
NSString *kExifTypeMotorola = @"4d4d";

@implementation UGCExifInfoProperties

- (instancetype)init {
    if (self = [super init]) {
        _byteTypeDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"1", @"1",
                            @"1", @"2",
                            @"2", @"3",
                            @"4", @"4",
                            @"8", @"5",
                            @"1", @"6",
                            @"1", @"7",
                            @"2", @"8",
                            @"4", @"9",
                            @"8", @"10",
                            @"4", @"11",
                            @"8", @"12", nil];
        _byteTypeNameDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"unsigned byte", @"1",
                            @"ascii strings", @"2",
                            @"unsigned short", @"3",
                            @"unsigned long", @"4",
                            @"unsigned rational", @"5",
                            @"signed byte", @"6",
                            @"undefined", @"7",
                            @"signed short", @"8",
                            @"signed long", @"9",
                            @"signed rational", @"10",
                            @"single float", @"11",
                            @"double float", @"12", nil];
        _flagNameDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"ImageDescription", kImageDescription,
                               @"Make", kMake,
                               @"Model", kModel,
                               @"Orientation", kOrientation,
                               @"XResolution", kXResolution,
                               @"YResolution", kYResolution,
                               @"ResolutionUnit", kResolutionUnit,
                               @"Software", kSoftware,
                               @"DateTime", kDateTime,
                               @"WhitePoint", kWhitePoint,
                               @"PrimaryChromaticities", kPrimaryChromaticities,
                               @"YCbCrCoefficients", kYCbCrCoefficients,
                               @"YCbCrPositioning", kYCbCrPositioning,
                               @"ReferenceBlackWhite", kReferenceBlackWhite,
                               @"Copyright", kCopyright,
                               @"ExifOffset", kExifOffset,
                               @"ExposureTime", kExposureTime,
                               @"FNumber", kFNumber,
                               @"ExposureProgram", kExposureProgram,
                               @"ISOSpeedRatings", kISOSpeedRatings,
                               @"ExifVersion", kExifVersion,
                               @"DateTimeOriginal", kDateTimeOriginal,
                               @"DateTimeDigitized", kDateTimeDigitized,
                               @"ComponentsConfiguration", kComponentsConfiguration,
                               @"CompressedBitsPerPixel", kCompressedBitsPerPixel,
                               @"ShutterSpeedValue", kShutterSpeedValue,
                               @"ApertureValue", kApertureValue,
                               @"BrightnessValue", kBrightnessValue,
                               @"ExposureBiasValue", kExposureBiasValue,
                               @"MaxApertureValue", kMaxApertureValue,
                               @"SubjectDistance", kSubjectDistance,
                               @"MeteringMode", kMeteringMode,
                               @"LightSource", kLightSource,
                               @"Flash", kFlash,
                               @"FocalLength", kFocalLength,
                               @"MakerNote", kMakerNote,
                               @"UserComment", kUserComment,
                               @"SubsecTime", kSubsecTime,
                               @"SubsecTimeOriginal", kSubsecTimeOriginal,
                               @"SubsecTimeDigitized", kSubsecTimeDigitized,
                               @"FlashPixVersion", kFlashPixVersion,
                               @"ColorSpace", kColorSpace,
                               @"ExifImageWidth", kExifImageWidth,
                               @"ExifImageHeight", kExifImageHeight,
                               @"RelatedSoundFile", kRelatedSoundFile,
                               @"ExifInteroperabilityOffset", kExifInteroperabilityOffset,
                               @"FocalPlaneXResolution", kFocalPlaneXResolution,
                               @"FocalPlaneYResolution", kFocalPlaneYResolution,
                               @"FocalPlaneResolutionUnit", kFocalPlaneResolutionUnit,
                               @"ExposureIndex", kExposureIndex,
                               @"SensingMethod", kSensingMethod,
                               @"FileSource", kFileSource,
                               @"SceneType", kSceneType,
                               @"CFAPattern", kCFAPattern,
                               @"InteroperabilityIndex", kInteroperabilityIndex,
                               @"InteroperabilityVersion", kInteroperabilityVersion,
                               @"RelatedImageFileFormat", kRelatedImageFileFormat,
                               @"RelatedImageWidth", kRelatedImageWidth,
                               @"ImageWidth", kImageWidth,
                               @"ImageLength", kImageLength,
                               @"BitsPerSample", kBitsPerSample,
                               @"Compression", kCompression,
                               @"PhotometricInterpretation", kPhotometricInterpretation,
                               @"StripOffsets", kStripOffsets,
                               @"SamplesPerPixel", kSamplesPerPixel,
                               @"RowsPerStrip", kRowsPerStrip,
                               @"StripByteConunts", kStripByteConunts,
                               @"PlanarConfiguration", kPlanarConfiguration,
                               @"JpegIFOffset", kJpegIFOffset,
                               @"JpegIFByteCount", kJpegIFByteCount,
                               @"YCbCrSubSampling", kYCbCrSubSampling,
                               @"NewSubfileType", kNewSubfileType,
                               @"SubfileType", kSubfileType,
                               @"TransferFunction", kTransferFunction,
                               @"Artist", kArtist,
                               @"Predictor", kPredictor,
                               @"TileWidth", kTileWidth,
                               @"TileLength", kTileLength,
                               @"TileOffsets", kTileOffsets,
                               @"TileByteCounts", kTileByteCounts,
                               @"SubIFDs", kSubIFDs,
                               @"JPEGTables", kJPEGTables,
                               @"CFARepeatPatternDim", kCFARepeatPatternDim,
                               @"CFAPatternMisc", kCFAPatternMisc,
                               @"BatteryLevel", kBatteryLevel,
                               @"InterColorProfile", kInterColorProfile,
                               @"SpectralSensitivity", kSpectralSensitivity,
                               @"GPSInfo", kGPSInfo,
                               @"OECF", kOECF,
                               @"Interlace", kInterlace,
                               @"TimeZoneOffset", kTimeZoneOffset,
                               @"SelfTimerMode", kSelfTimerMode,
                               @"FlashEnergy", kFlashEnergy,
                               @"SpatialFrequencyResponse", kSpatialFrequencyResponse,
                               @"Noise", kNoise,
                               @"ImageNumber", kImageNumber,
                               @"SecurityClassification", kSecurityClassification,
                               @"ImageHistory", kImageHistory,
                               @"SubjectLocation", kSubjectLocation,
                               @"ExposureIndexMisc", kExposureIndexMisc,
                               @"FlashEnergyMisc", kFlashEnergyMisc,
                               @"SpatialFrequencyResponseMisc", kSpatialFrequencyResponseMisc,
                               @"SubjectLocationMisc", kSubjectLocationMisc, nil];
        
    }
    return self;
}

- (NSString *)strValueFromKey:(NSString *)key fValueArray:(NSArray<NSNumber *> *)array {
    NSMutableString *str = [NSMutableString new];
    if ([key isEqualToString:kResolutionUnit] || [key isEqualToString:kFocalPlaneResolutionUnit]) {
        NSNumber *unit = [array firstObject];
        switch ([unit intValue]) {
            case 1:
                [str appendString:@"none"];
                break;
            case 2:
                [str appendString:@"inches"];
                break;
            case 3:
                [str appendString:@"centimeter"];
                break;
            default:
                [str appendString:@"none"];
                break;
        }
    }else if ([key isEqualToString:kPrimaryChromaticities] || [key isEqualToString:kYCbCrCoefficients]) {
        for (int i = 0; i < array.count; i++) {
            if (i != 0) {
                [str appendString:@","];
            }
            NSNumber *num = array[i];
            [str appendFormat:@"%.3f",[num floatValue]];
        }
    }else if ([key isEqualToString:kYCbCrPositioning]) {
        NSNumber *unit = [array firstObject];
        switch ([unit intValue]) {
            case 1:
                [str appendString:@"Center"];
                break;
            case 2:
                [str appendString:@"Baseline Point"];
                break;
            default:
                break;
        }
    }else if ([key isEqualToString:kExposureProgram]) {
        NSNumber *unit = [array firstObject];
        switch ([unit intValue]) {
            case 1:
                [str appendString:@"手动曝光"];
                break;
            case 2:
                [str appendString:@"正常程序曝光"];
                break;
            case 3:
                [str appendString:@"光圈优先曝光"];
                break;
            case 4:
                [str appendString:@"快门优先曝光"];
                break;
            case 5:
                [str appendString:@"慢速程序"];
                break;
            case 6:
                [str appendString:@"高速程序"];
                break;
            case 7:
                [str appendString:@"肖像模式"];
                break;
            case 8:
                [str appendString:@"风景模式"];
                break;
            default:
                break;
        }
    }else if ([key isEqualToString:kMeteringMode]) {
        NSNumber *unit = [array firstObject];
        switch ([unit intValue]) {
            case 0:
                [str appendString:@"未知"];
                break;
            case 1:
                [str appendString:@"平均测光"];
                break;
            case 2:
                [str appendString:@"中央重点测光"];
                break;
            case 3:
                [str appendString:@"点测光"];
                break;
            case 4:
                [str appendString:@"多点测光"];
                break;
            case 5:
                [str appendString:@"多区域测光"];
                break;
            case 6:
                [str appendString:@"部分测光"];
                break;
            case 255:
                [str appendString:@"其他"];
                break;
            default:
                break;
        }
    }else if ([key isEqualToString:kLightSource]) {
        NSNumber *unit = [array firstObject];
        switch ([unit intValue]) {
            case 0:
                [str appendString:@"未知"];
                break;
            case 1:
                [str appendString:@"日光"];
                break;
            case 2:
                [str appendString:@"荧光灯"];
                break;
            case 3:
                [str appendString:@"白炽灯"];
                break;
            case 10:
                [str appendString:@"闪光灯"];
                break;
            case 17:
                [str appendString:@"标准光A"];
                break;
            case 18:
                [str appendString:@"标准光B"];
                break;
            case 19:
                [str appendString:@"标准光C"];
                break;
            case 20:
                [str appendString:@"D55"];
                break;
            case 21:
                [str appendString:@"D65"];
                break;
            case 22:
                [str appendString:@"D75"];
                break;
            case 255:
                [str appendString:@"其他"];
                break;
            default:
                break;
        }
    }else if ([key isEqualToString:kCompression]) {
        NSNumber *unit = [array firstObject];
        switch ([unit intValue]) {
            case 1:
                [str appendString:@"非压缩"];
                break;
            case 6:
                [str appendString:@"JPEG压缩"];
                break;
            default:
                break;
        }
    }else if ([key isEqualToString:kPhotometricInterpretation]) {
        NSNumber *unit = [array firstObject];
        switch ([unit intValue]) {
            case 1:
                [str appendString:@"单色"];
                break;
            case 2:
                [str appendString:@"RGB"];
                break;
            case 6:
                [str appendString:@"YCbCr"];
                break;
            default:
                break;
        }
    }else {
        for (int i = 0; i < array.count; i++) {
            if (i != 0) {
                [str appendString:@","];
            }
            NSNumber *num = array[i];
            [str appendFormat:@"%d",[num intValue]];
        }
    }
    
    return str;
}

@end