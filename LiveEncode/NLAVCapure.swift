//
//  NLAVCapure.swift
//  LiveEncode
//
//  Created by neulion on 8/9/17.
//  Copyright © 2017 NeuLion. All rights reserved.
//

import UIKit
import AVFoundation

class NLAVCapure: NSObject {
    
    var captureSession:AVCaptureSession!
    func startCapture() -> Bool{
        if(!self.createCaptureSection()){
            return false
        }
        captureSession.startRunning()
        
        return true
    }
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
        return true
    }
    
    func getPreviewLayer() -> AVCaptureVideoPreviewLayer{
       return AVCaptureVideoPreviewLayer.init(session:captureSession)
    }
}

extension NLAVCapure: AVCaptureAudioDataOutputSampleBufferDelegate{
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        
    }
}

extension NLAVCapure: AVCaptureVideoDataOutputSampleBufferDelegate{
    func captureOutput(_ captureOutput: AVCaptureOutput!, didDrop sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        
    }
}
