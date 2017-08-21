//
//  XLExifInfoProperties.h
//  ExifDemo
//
//  Created by 薛琳 on 16/4/23.
//  Copyright © 2016年 Welson. All rights reserved.
//

#import <Foundation/Foundation.h>

//IFD0 (主图像)使用的标签
extern NSString *kImageDescription;
extern NSString *kMake;
extern NSString *kModel;
extern NSString *kOrientation;
extern NSString *kXResolution;
extern NSString *kYResolution;
extern NSString *kResolutionUnit;
extern NSString *kSoftware;
extern NSString *kDateTime;
extern NSString *kWhitePoint;
extern NSString *kPrimaryChromaticities;
extern NSString *kYCbCrCoefficients;
extern NSString *kYCbCrPositioning;
extern NSString *kReferenceBlackWhite;
extern NSString *kCopyright;
extern NSString *kExifOffset;

//Exif 子IFD使用的标签
extern NSString *kExposureTime;
extern NSString *kFNumber;
extern NSString *kExposureProgram;
extern NSString *kISOSpeedRatings;
extern NSString *kExifVersion;
extern NSString *kDateTimeOriginal;
extern NSString *kDateTimeDigitized;
extern NSString *kComponentsConfiguration;
extern NSString *kCompressedBitsPerPixel;
extern NSString *kShutterSpeedValue;
extern NSString *kApertureValue;
extern NSString *kBrightnessValue;
extern NSString *kExposureBiasValue;
extern NSString *kMaxApertureValue;
extern NSString *kSubjectDistance;
extern NSString *kMeteringMode;
extern NSString *kLightSource;
extern NSString *kFlash;
extern NSString *kFocalLength;
extern NSString *kMakerNote;
extern NSString *kUserComment;
extern NSString *kSubsecTime;
extern NSString *kSubsecTimeOriginal;
extern NSString *kSubsecTimeDigitized;
extern NSString *kFlashPixVersion;
extern NSString *kColorSpace;
extern NSString *kExifImageWidth;
extern NSString *kExifImageHeight;
extern NSString *kRelatedSoundFile;
extern NSString *kExifInteroperabilityOffset;
extern NSString *kFocalPlaneXResolution;
extern NSString *kFocalPlaneYResolution;
extern NSString *kFocalPlaneResolutionUnit;
extern NSString *kExposureIndex;
extern NSString *kSensingMethod;
extern NSString *kFileSource;
extern NSString *kSceneType;
extern NSString *kCFAPattern;

//Interoperability IFD
extern NSString *kInteroperabilityIndex;
extern NSString *kInteroperabilityVersion;
extern NSString *kRelatedImageFileFormat;
extern NSString *kRelatedImageWidth;

//IFD1 (缩略图)使用的标签
extern NSString *kImageWidth;
extern NSString *kImageLength;
extern NSString *kBitsPerSample;
extern NSString *kCompression;
extern NSString *kPhotometricInterpretation;
extern NSString *kStripOffsets;
extern NSString *kSamplesPerPixel;
extern NSString *kRowsPerStrip;
extern NSString *kStripByteConunts;
extern NSString *kPlanarConfiguration;
extern NSString *kJpegIFOffset;
extern NSString *kJpegIFByteCount;
extern NSString *kYCbCrSubSampling;

//Misc Tags
extern NSString *kNewSubfileType;
extern NSString *kSubfileType;
extern NSString *kTransferFunction;
extern NSString *kArtist;
extern NSString *kPredictor;
extern NSString *kTileWidth;
extern NSString *kTileLength;
extern NSString *kTileOffsets;
extern NSString *kTileByteCounts;
extern NSString *kSubIFDs;
extern NSString *kJPEGTables;
extern NSString *kCFARepeatPatternDim;
extern NSString *kCFAPatternMisc;
extern NSString *kBatteryLevel;
extern NSString *kInterColorProfile;
extern NSString *kSpectralSensitivity;
extern NSString *kGPSInfo;
extern NSString *kOECF;
extern NSString *kInterlace;
extern NSString *kTimeZoneOffset;
extern NSString *kSelfTimerMode;
extern NSString *kFlashEnergy;
extern NSString *kSpatialFrequencyResponse;
extern NSString *kNoise;
extern NSString *kImageNumber;
extern NSString *kSecurityClassification;
extern NSString *kImageHistory;
extern NSString *kSubjectLocation;
extern NSString *kExposureIndexMisc;
extern NSString *kFlashEnergyMisc;
extern NSString *kSpatialFrequencyResponseMisc;
extern NSString *kSubjectLocationMisc;

extern NSString *kExifEndFlag;
extern NSString *kExifStartFlag;
extern NSString *kExifTypeIntel;
extern NSString *kExifTypeMotorola;

@interface UGCExifInfoProperties : NSObject

@property (nonatomic, copy, readonly) NSDictionary *byteTypeDictionary;
@property (nonatomic, copy, readonly) NSDictionary *byteTypeNameDictionary;
@property (nonatomic, copy, readonly) NSDictionary *flagNameDictionary;

- (NSString *)strValueFromKey:(NSString *)key fValueArray:(NSArray<NSNumber *> *)array;

@end
