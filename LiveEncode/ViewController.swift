//
//  ViewController.swift
//  LiveEncode
//
//  Created by neulion on 8/9/17.
//  Copyright © 2017 NeuLion. All rights reserved.
//

import UIKit
import Photos
import AVFoundation

class ViewController: UIViewController {

    var avCapture:NLAVCapure?
    var avEncoder:NLAVEncoder?
    var captureTime:Timer?
    override func viewDidLoad() {
        super.viewDidLoad()
        PHPhotoLibrary.authorizationStatus()

        avCapture = NLAVCapure();
        var videoSetting = VideoEncoderSetting()
        videoSetting.bitrate = 3000000
        videoSetting.height = 720
        videoSetting.width = 1280
        videoSetting.framerate = 15
        videoSetting.videoProfile = 3000000
        videoSetting.videoCodec = AVVideoCodecH264
        var audioSetting = AudioEncoderSetting()
        audioSetting.bitrate = 6400000
        audioSetting.channelCount = 2
        audioSetting.sampleRate = 48000
        audioSetting.audioCodec = kAudioFormatMPEG4AAC
        avEncoder = NLAVEncoder()
        avEncoder?.config(videoSetting: videoSetting, audioSetting: audioSetting)
        
        avCapture?.nextProcesser = avEncoder
        avCapture?.startProcess()
        avEncoder?.startProcess()
        
        captureTime = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(enterBackGround), userInfo: nil, repeats: false)
        //avCapture?.startCapture()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let layer = avCapture?.getPreviewLayer(){
            layer.frame = self.view.bounds
            layer.borderColor =  UIColor.red.cgColor
            layer.borderWidth = 1
            self.view.layer.addSublayer(layer)
        }
        
    }
    
    func enterBackGround() {
        avCapture?.stopProcess()
        avEncoder?.stopProcess()
    }


}

