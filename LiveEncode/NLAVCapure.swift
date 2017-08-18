//
//  NLAVCapure.swift
//  LiveEncode
//
//  Created by neulion on 8/9/17.
//  Copyright © 2017 NeuLion. All rights reserved.
//

import UIKit
import AVFoundation

class NLAVCapure: AVProcesser {
    
    var captureSession:AVCaptureSession!
    var connectAudio:AVCaptureConnection?
    var connectVideo:AVCaptureConnection?
    var outVideoFormat:NLMediaFormatInfo!
    var outAudioFormat:NLMediaFormatInfo!
    
    func createCaptureSection() -> Bool{
        captureSession = AVCaptureSession.init()
        
        let audioDevice = try? AVCaptureDeviceInput.init(device:AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio))
        if !captureSession.canAddInput(audioDevice){
            return false
        }
        captureSession.addInput(audioDevice)
        let audioOutput = AVCaptureAudioDataOutput.init()
        let audioQueue = DispatchQueue(label: "audio queue")
        audioOutput.setSampleBufferDelegate(self, queue: audioQueue)
        if !captureSession.canAddOutput(audioOutput){
            return false
        }
        captureSession.addOutput(audioOutput)
        
        guard let connectAudio = audioOutput.connection(withMediaType: AVMediaTypeAudio) else{
            return false
        }
        self.connectAudio = connectAudio
        
        let videoDevice = try? AVCaptureDeviceInput.init(device: AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo))
        if !captureSession.canAddInput(videoDevice){
            return false
        }
        captureSession.addInput(videoDevice)
        let videoOutput = AVCaptureVideoDataOutput.init()
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as? NSString ?? "":NSNumber.init(value:kCVPixelFormatType_32BGRA)]
        let videoQueue = DispatchQueue(label: "video queue")
        videoOutput.setSampleBufferDelegate(self, queue: videoQueue)
        if !captureSession.canAddOutput(videoOutput){
            return false
        }
        captureSession.addOutput(videoOutput)
        
        guard let connectVideo = videoOutput.connection(withMediaType: AVMediaTypeVideo) else {
            return false
        }
        self.connectVideo = connectVideo
        return true
    }
    
    func getPreviewLayer() -> AVCaptureVideoPreviewLayer{
       return AVCaptureVideoPreviewLayer.init(session:captureSession)
    }
    
    override init() {
        outVideoFormat = NLMediaFormatInfo(type: .mediaVideo, subtype: .video32BGRA)
        outAudioFormat = NLMediaFormatInfo(type: .mediaAudio, subtype: .audioPCM)
    }
    override func startProcess() -> Bool{
        if(!self.createCaptureSection()){
            return false
        }
        captureSession.startRunning()
        self.isStarted = true
        return true
    }
    override func stopProcess() -> Bool{
        captureSession.stopRunning()
        self.isStarted = false
        return true
    }
}

extension NLAVCapure: AVCaptureAudioDataOutputSampleBufferDelegate,AVCaptureVideoDataOutputSampleBufferDelegate{
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        
        let time = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        guard let discription = CMSampleBufferGetFormatDescription(sampleBuffer) else {
            return
        }
        
        if  self.connectVideo == connection {
            let videoDimension = CMVideoFormatDescriptionGetDimensions(discription)
            let subType = CMFormatDescriptionGetMediaSubType(discription)
            var mediaFormat = NLMediaFormatInfo(type: .mediaVideo, subtype: .video32BGRA)
            var nlSample = NLMediaSample()
            nlSample.DTS = time.value*1000/Int64(time.timescale)
            nlSample.sampleBuffer = sampleBuffer
            nlSample.mediaFormat = mediaFormat
            sendOutSample(nlSample)
            
        }else if self.connectAudio == connection{
            var mediaFormat = NLMediaFormatInfo(type: .mediaAudio, subtype: .audioPCM)
            var nlSample = NLMediaSample()
            nlSample.DTS = time.value*1000/Int64(time.timescale)
            nlSample.sampleBuffer = sampleBuffer
            nlSample.mediaFormat = mediaFormat
            sendOutSample(nlSample)
        }
    }
}

//extension NLAVCapure: AVCaptureVideoDataOutputSampleBufferDelegate{
//    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
//        
//    }
//}
