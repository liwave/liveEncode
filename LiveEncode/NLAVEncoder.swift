//
//  NLAVEncoder.swift
//  LiveEncode
//
//  Created by neulion on 8/14/17.
//  Copyright © 2017 NeuLion. All rights reserved.
//

import UIKit
import Photos
import AVFoundation

struct VideoEncoderSetting {
    var bitrate:Int!
    var height:Int!
    var width:Int!
    var framerate:Int!
    var videoProfile:Int!
    var videoCodec:String!
}
struct AudioEncoderSetting {
    var sampleRate:Int!
    var channelCount:Int!
    var bitrate:Int!
    var audioCodec:UInt32!
}

class NLAVEncoder: AVProcesser {

    var inputVideoFormat:NLMediaFormatInfo!
    var inputAudioFormat:NLMediaFormatInfo!
    var videoAsWriter:AVAssetWriterInput!
    var audioAsWriter:AVAssetWriterInput!
    var avAssetWriter:AVAssetWriter!
    var isSectionStart:Bool = false
    override init() {
        inputVideoFormat = NLMediaFormatInfo(type: .mediaVideo, subtype: .video32BGRA)
        inputAudioFormat = NLMediaFormatInfo(type: .mediaAudio, subtype: .audioPCM)

    }
    
    override func isSupportFormat(_ mediaFormat:NLMediaFormatInfo?) ->Bool{
        if mediaFormat?.mediaType == inputVideoFormat.mediaType && mediaFormat?.subMediatype == inputVideoFormat.subMediatype {
            return true
        }
        if mediaFormat?.mediaType == inputAudioFormat.mediaType && mediaFormat?.subMediatype == inputAudioFormat.subMediatype {
            return true
        }
        
        return false
    }
    
    override func startProcess() -> Bool{
        if !avAssetWriter.startWriting() {
            avAssetWriter.error
            return false
        }
        self.isStarted = true
        return true
    }
    override func stopProcess() -> Bool{
        avAssetWriter.cancelWriting()
        self.isStarted = false
        self.saveVideotoPhotoAlbum()
        return true
    }
    
    override func avProcess(_ sample: NLMediaSample!){
        
        if !isSectionStart{
            isSectionStart = true
            avAssetWriter.startSession(atSourceTime: CMSampleBufferGetPresentationTimeStamp(sample.sampleBuffer))
        }
        if sample.mediaFormat.mediaType == .mediaVideo {
            if videoAsWriter.isReadyForMoreMediaData {
                videoAsWriter.append(sample.sampleBuffer)
            }
        }else if sample.mediaFormat.mediaType == .mediaAudio {
            if audioAsWriter.isReadyForMoreMediaData{
                audioAsWriter.append(sample.sampleBuffer)
            }
        }
    }
    
    func saveVideotoPhotoAlbum() {
        NLGlobalUtils.saveVideoAsset(withPath: StoragePath.OriginalPhotoPath + "/1.mp4", groupName: "capture")

    }
    func config(videoSetting:VideoEncoderSetting!, audioSetting:AudioEncoderSetting! ){
        let videoProperty:[String:Any] = [AVVideoAverageBitRateKey:videoSetting.bitrate, AVVideoMaxKeyFrameIntervalKey:videoSetting.framerate]
        let videoOutputSetting:[String : Any] = [AVVideoCodecKey:AVVideoCodecH264,
                             AVVideoWidthKey:NSNumber.init(value: videoSetting.width),
                             AVVideoHeightKey:NSNumber.init(value: videoSetting.height),
                             AVVideoCompressionPropertiesKey:videoProperty]
        videoAsWriter = AVAssetWriterInput.init(mediaType: AVMediaTypeVideo, outputSettings:videoOutputSetting)
        
        let audioOutputSetting:[String : Any] = [AVEncoderBitRatePerChannelKey:audioSetting.bitrate,
                                                 AVFormatIDKey:audioSetting.audioCodec,
                                                 AVNumberOfChannelsKey:audioSetting.channelCount,
                                                 AVSampleRateKey:audioSetting.sampleRate]
        
        audioAsWriter = AVAssetWriterInput.init(mediaType: AVMediaTypeAudio, outputSettings: audioOutputSetting)
        
        let fileName = StoragePath.OriginalPhotoPath + "/1.mp4"
        let fileManger = FileManager()
        if fileManger.fileExists(atPath: fileName){
            try? fileManger.removeItem(at: URL(fileURLWithPath:fileName))
        }
        avAssetWriter = try? AVAssetWriter.init(url:URL(fileURLWithPath:fileName), fileType:AVFileTypeMPEG4)
        
        if avAssetWriter.canAdd(videoAsWriter){
            avAssetWriter.add(videoAsWriter)
        }
        if avAssetWriter.canAdd(audioAsWriter){
            avAssetWriter.add(audioAsWriter)
        }
        
    }
    
}

