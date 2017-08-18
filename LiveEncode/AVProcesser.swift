//
//  AVProcesser.swift
//  LiveEncode
//
//  Created by neulion on 8/14/17.
//  Copyright © 2017 NeuLion. All rights reserved.
//

import UIKit
import AVFoundation
enum NLMediaType{
    case mediaVideo
    case mediaAudio
    case mediaData
}
enum NLSubMediaType{
    case videoYUV420
    case video32BGRA
    case videoH264
    case audioPCM
    case audioAAC
}
struct NLMediaFormatInfo {
    var mediaType:NLMediaType
    var subMediatype:NLSubMediaType
    init(type:NLMediaType, subtype:NLSubMediaType){
        mediaType = type
        subMediatype = subtype
    }
    func isSameFormat(_ mediaFormat:NLMediaFormatInfo!) -> Bool {
        if mediaFormat.mediaType == self.mediaType && mediaFormat.subMediatype == self.subMediatype{
            return true
        }
        return false
    }
}

struct NLMediaSample{
    var sampleBuffer: CMSampleBuffer!
    var mediaFormat:NLMediaFormatInfo!
    var PTS:Int64?
    var DTS:Int64?
}

protocol NLAVDataDelegate:class {
    func receiveSample(_ sample: NLMediaSample!)
}

class AVProcesser: NSObject{
    var inputMediaFormat:NLMediaFormatInfo!
    var outputMediaFormat:NLMediaFormatInfo!
    weak var nextProcesser:NLAVDataDelegate?
    var isStarted = false
    
    override init() {
    }
    func isSupportFormat(_ mediaFormat:NLMediaFormatInfo?) ->Bool{
        if mediaFormat?.mediaType == inputMediaFormat.mediaType && mediaFormat?.subMediatype == inputMediaFormat.subMediatype {
            return true
        }
        return false
    }
    func startProcess() -> Bool{
        return true
    }
    func stopProcess() -> Bool{
        return true
    }
    func avProcess(_ sample: NLMediaSample!){
        
    }
    func sendOutSample(_ sample: NLMediaSample!){
        nextProcesser?.receiveSample(sample)
    }
}

extension AVProcesser:NLAVDataDelegate{
    func receiveSample(_ sample: NLMediaSample!) {
        if !isStarted {
            return
        }
        if isSupportFormat(sample.mediaFormat) {
            avProcess(sample)
        }else{
            sendOutSample(sample)
        }
    }
}
