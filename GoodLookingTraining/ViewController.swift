//
//  ViewController.swift
//  GoodLookingTraining
//
//  Created by 間嶋大輔 on 2020/02/05.
//  Copyright © 2020 daisuke. All rights reserved.
//

import UIKit
import Vision
import AVFoundation
import CoreHaptics
import AudioToolbox
import ReplayKit


class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate,RPPreviewViewControllerDelegate {
    
    var oneSecondTimer = 0
    var resultLabel:UILabel!
    var totalPointLabel:UILabel!
    var time = 0
    var oneSecond = 0
    var displayTimer:Double = 0
    var ikemenCount:Double = 0
    
    var cameraPreviewLayer : AVCaptureVideoPreviewLayer?

    var recordingLabel = UILabel()
    var cameraLabel = UILabel()
    var CameraButton = UIImageView()
    var helpLabel = UILabel()
    var HelpButton = UIImageView()

    var isRecording = false
    let sharedRecorder = RPScreenRecorder.shared()
    var recordButton = UILabel()
    var recordingAnimationButton = UILabel()
    var backgroundView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UserDefaults.standard.string(forKey: "notFirst") != nil {
                        print("already launched")
                        } else {
                        print("first!")
                        performSegue(withIdentifier: "InitialTerm", sender: self)
                        }
        navigationController?.navigationBar.isHidden = true
        
        // Do any additional setup after loading the view.
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { (Timer) in
           
            self.oneSecondTimer += 1
            if self.oneSecondTimer == 5 {
                 self.isRequest = true
                self.oneSecondTimer = 0
            }
            
//            self.oneSecond += 1
//            if self.oneSecond == 10 {
//                self.oneSecond = 0
//            self.displayTimer += 1
//            let ikemenPerSecond = floor(self.ikemenCount / self.displayTimer * 600) * 0.1
//
//            self.totalPointLabel.text = "\(self.displayTimer)秒\ntotal\(self.ikemenCount)\n\(ikemenPerSecond)イケ/分"
//                }
        }
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setupAVCapture()
               setupPreviewLayer()
               setupLabel()
               sharedRecorder.isMicrophoneEnabled = true
               createEngine()
        session.startRunning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        session.stopRunning()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        buttonSetting()
    }
    
    @objc func tapRecordButton(){
             moviewRecord()
     }
    private func presentAlert(_ title: String) {
        
        let alertController = UIAlertController(title: title,
                                                message: NSLocalizedString("iPhoneX、iOS13以降が必要です", comment: ""),
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK",
                                     style: .default) { _ in
                                        alertController.dismiss(animated: true, completion: nil)
                                        
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        DispatchQueue.main.async { [unowned previewController] in
            //            self.initializeConfig()
            previewController.dismiss(animated: true, completion: nil)
        }
    }
    
    private func moviewRecord() {
        recordingButtonStyling()
        if !isRecording {
            AudioServicesPlaySystemSound(1117)
            CameraButton.isHidden = true
            HelpButton.isHidden = true
            recordingLabel.isHidden = false
            helpLabel.isHidden = true
            cameraLabel.isHidden = true
            backgroundView.isHidden = true
            
            isRecording = true
            sharedRecorder.startRecording(handler: { (error) in
                if let error = error {
                    print(error)
                }
            })
        } else {
            AudioServicesPlaySystemSound(1118)
            isRecording = false
            CameraButton.isHidden = false
            HelpButton.isHidden = false
            recordingLabel.isHidden = true
            helpLabel.isHidden = false
            cameraLabel.isHidden = false
            backgroundView.isHidden = false
            sharedRecorder.stopRecording(handler: { (previewViewController, error) in
                previewViewController?.previewControllerDelegate = self
                self.present(previewViewController!, animated: true, completion: nil)
            })
        }
    }
    
    @objc func helpSegue(){
        performSegue(withIdentifier: "ShowHelp", sender: nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: NSLocalizedString("保存しました!",value: "saved!", comment: ""), message: NSLocalizedString("フォトライブラリに保存しました",value: "Saved in photo library", comment: ""), preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    private let sessionQueue = DispatchQueue(label: "session queue")
    var cameraPosition = false
    
    @objc func switchCamera(){
        cameraPosition.toggle()
            CameraButton.isUserInteractionEnabled = false
            recordButton.isEnabled = false
            sessionQueue.async {
                
                let preferredPosition: AVCaptureDevice.Position
                
                switch self.cameraPosition {
                case false:
                    preferredPosition = .back
                case true:
                    preferredPosition = .front
                }

                guard let videoDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: preferredPosition).devices.first else {return}

                    do {
                        let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
                        
                        self.session.beginConfiguration()
                        
                        self.session.removeInput(self.videoDeviceInput)
                        
                        if self.session.canAddInput(videoDeviceInput) {
                            
                            self.session.addInput(videoDeviceInput)
                            self.videoDeviceInput = videoDeviceInput
                        } else {
                            self.session.addInput(self.videoDeviceInput)
                        }
                        
                        self.session.commitConfiguration()
                    } catch {
                        print("Error occurred while creating video device input: \(error)")
                    }
                }
                
                DispatchQueue.main.async {
                    self.CameraButton.isUserInteractionEnabled = true
                    self.recordButton.isEnabled = true
                }
    }
    
    private func buttonSetting() {
         if UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight {
             backgroundView.frame = CGRect(x: view.bounds.maxX - (view.bounds.width * 0.25), y: 0, width: view.bounds.width  * 0.25, height: view.bounds.height)
             let buttonHeight = backgroundView.bounds.width * 0.33
             recordButton.frame = CGRect(x: backgroundView.center.x - (buttonHeight * 0.8) , y: backgroundView.center.y - (buttonHeight * 0.5), width: buttonHeight, height: buttonHeight)
             recordingAnimationButton.frame = CGRect(x: buttonHeight * 0.05, y: buttonHeight * 0.05, width: buttonHeight * 0.9, height: buttonHeight * 0.9)
             
             HelpButton.frame = CGRect(x: backgroundView.center.x - (buttonHeight * 0.8) , y: backgroundView.center.y + (buttonHeight * 2), width: buttonHeight * 0.5, height: buttonHeight * 0.5)
             helpLabel.frame = CGRect(x: backgroundView.center.x - (buttonHeight * 0.2), y: backgroundView.center.y + (buttonHeight * 2), width: buttonHeight * 0.5, height: buttonHeight * 0.5)
             CameraButton.frame = CGRect(x: backgroundView.center.x - (buttonHeight * 0.8) , y: backgroundView.center.y - (buttonHeight * 2.5), width: buttonHeight * 0.5, height: buttonHeight * 0.5)
             cameraLabel.frame = CGRect(x: backgroundView.center.x - (buttonHeight * 0.2), y: backgroundView.center.y - (buttonHeight * 2.5), width: buttonHeight * 0.5, height: buttonHeight * 0.5)
             recordingLabel.frame = CGRect(x: view.bounds.maxX - 150, y: view.bounds.maxY - 100, width: 100, height: 100)
             recordingLabel.frame = CGRect(x: recordButton.frame.origin.x, y: recordButton.frame.maxY, width: buttonHeight, height: buttonHeight)
             
         } else {
             backgroundView.frame = CGRect(x: 0, y: view.bounds.maxY - (view.bounds.height * 0.25), width: view.bounds.width, height: view.bounds.height * 0.25)
             let buttonHeight = backgroundView.bounds.height * 0.33
             recordButton.frame = CGRect(x: backgroundView.center.x - (buttonHeight * 0.5), y: backgroundView.center.y - (buttonHeight * 0.8), width: buttonHeight, height: buttonHeight)
             recordingAnimationButton.frame = CGRect(x: buttonHeight * 0.05, y: buttonHeight * 0.05, width: buttonHeight * 0.9, height: buttonHeight * 0.9)
             
             HelpButton.frame = CGRect(x: backgroundView.center.x - (buttonHeight * 2.5), y: backgroundView.center.y - (buttonHeight * 0.8), width: buttonHeight * 0.5, height: buttonHeight * 0.5)
             helpLabel.frame = CGRect(x: backgroundView.center.x - (buttonHeight * 2.5), y: backgroundView.center.y - (buttonHeight * 0.3) , width: buttonHeight * 0.5, height: buttonHeight * 0.5)
             CameraButton.frame = CGRect(x: backgroundView.center.x + (buttonHeight * 2), y: backgroundView.center.y - (buttonHeight * 0.8), width: buttonHeight * 0.5, height: buttonHeight * 0.5)
             cameraLabel.frame = CGRect(x: backgroundView.center.x + (buttonHeight * 2), y: backgroundView.center.y - (buttonHeight * 0.3) , width: buttonHeight * 0.5, height: buttonHeight * 0.5)
             recordingLabel.frame = CGRect(x: view.bounds.maxX - 150, y: view.bounds.maxY - 100, width: 100, height: 100)
             recordingLabel.frame = CGRect(x: recordButton.frame.origin.x, y: recordButton.frame.maxY, width: buttonHeight, height: buttonHeight)
         }
                  
         CameraButton.image = UIImage(systemName: "arrow.2.circlepath")
         HelpButton.image = UIImage(systemName: "questionmark.circle")
         cameraLabel.text = NSLocalizedString("Switch", comment: "")
         helpLabel.text = NSLocalizedString("Help", comment: "")

         
         HelpButton.tintColor = UIColor.darkGray
         CameraButton.tintColor = UIColor.darkGray
         helpLabel.textColor = UIColor.darkGray
         cameraLabel.textColor = UIColor.darkGray
         
         helpLabel.textAlignment = .center
         cameraLabel.textAlignment = .center
         helpLabel.adjustsFontSizeToFitWidth = true
         cameraLabel.adjustsFontSizeToFitWidth = true

         recordingLabel.text = NSLocalizedString("Recording", comment: "")
         recordingLabel.textColor = UIColor.red
         recordingLabel.adjustsFontSizeToFitWidth = true
         
         recordButton.layer.backgroundColor = UIColor.clear.cgColor
         recordButton.layer.borderColor = UIColor.white.cgColor
         recordButton.layer.borderWidth = 4
         recordButton.clipsToBounds = true
         recordButton.layer.cornerRadius = min(recordButton.frame.width, recordButton.frame.height) * 0.5
         
         recordingAnimationButton.layer.backgroundColor = UIColor.white.cgColor
         recordingAnimationButton.clipsToBounds = true
         recordingAnimationButton.layer.cornerRadius = min(recordingAnimationButton.frame.width, recordingAnimationButton.frame.height) * 0.5
         recordingAnimationButton.layer.borderWidth = 2
         recordingAnimationButton.layer.borderColor = UIColor.darkGray.cgColor
         backgroundView.backgroundColor = UIColor.white
         backgroundView.alpha = 0.5
         
         let symbolConfig = UIImage.SymbolConfiguration(weight: .thin)
         
         CameraButton.preferredSymbolConfiguration = symbolConfig
         CameraButton.contentMode = .scaleAspectFill
         HelpButton.preferredSymbolConfiguration = symbolConfig
         HelpButton.contentMode = .scaleAspectFill
         
         view.addSubview(backgroundView)
         view.addSubview(CameraButton)
         view.addSubview(HelpButton)
         view.addSubview(recordingLabel)
         view.addSubview(helpLabel)
         view.addSubview(cameraLabel)
 
         view.bringSubviewToFront(recordingLabel)
         view.bringSubviewToFront(HelpButton)
         view.bringSubviewToFront(CameraButton)
         view.bringSubviewToFront(helpLabel)
         view.bringSubviewToFront(cameraLabel)
 
         view.addSubview(recordButton)
         view.bringSubviewToFront(recordButton)
         recordButton.addSubview(recordingAnimationButton)
         recordingLabel.isHidden = true
         
         recordButton.isUserInteractionEnabled = true
         recordingAnimationButton.isUserInteractionEnabled = true
         HelpButton.isUserInteractionEnabled = true
         CameraButton.isUserInteractionEnabled = true
         helpLabel.isUserInteractionEnabled = true
         cameraLabel.isUserInteractionEnabled = true
         
         let helpTap = UITapGestureRecognizer(target: self, action: #selector(helpSegue))
         let helpTap4Label = UITapGestureRecognizer(target: self, action: #selector(helpSegue))
         
         HelpButton.addGestureRecognizer(helpTap)
         helpLabel.addGestureRecognizer(helpTap4Label)
         
         let cameraTap = UITapGestureRecognizer(target: self, action: #selector(switchCamera))
         let cameraTap4Label = UITapGestureRecognizer(target: self, action: #selector(switchCamera))
         
         CameraButton.addGestureRecognizer(cameraTap)
         cameraLabel.addGestureRecognizer(cameraTap4Label)
         
         let recordTap = UITapGestureRecognizer(target: self, action: #selector(tapRecordButton))
         recordButton.addGestureRecognizer(recordTap)
         let recordTap4Label = UITapGestureRecognizer(target: self, action: #selector(tapRecordButton))
         recordingAnimationButton.addGestureRecognizer(recordTap4Label)
     }
    
    private func recordingButtonStyling(){
         let buttonHeight = recordButton.bounds.height
         var time = 0
         if !isRecording {
             UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, options: [], animations: {
                 self.recordButton.layer.borderColor = UIColor.white.cgColor
                 self.recordButton.alpha = 0.5
             
                 self.recordingAnimationButton.frame = CGRect(x: buttonHeight * 0.25, y: buttonHeight * 0.25, width: buttonHeight * 0.5, height: buttonHeight * 0.5)
                 self.recordingAnimationButton.layer.backgroundColor = UIColor.clear.cgColor
                 self.recordingAnimationButton.clipsToBounds = true
                 self.recordingAnimationButton.layer.cornerRadius = min(self.recordingAnimationButton.frame.width, self.recordingAnimationButton.frame.height) * 0.1
                 self.recordingAnimationButton.layer.borderWidth = 2
                 self.recordingAnimationButton.layer.borderColor = UIColor.red.cgColor
                 self.recordingAnimationButton.alpha = 0.5
                 }, completion: { comp in
                     UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 1.0, delay: 1.0, options: [], animations: {
                         self.recordingLabel.alpha = 0
                         time += 1
                     },completion:  { (comp) in
                         UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 1.0, delay: 1.0, options: [], animations: {
                         self.recordingLabel.alpha = 1
                         })
                     })
             })
         } else {
             UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, options: [], animations: {
                 self.recordButton.layer.borderColor = UIColor.white.cgColor
                 self.recordButton.alpha = 1.0
         
                 self.recordingAnimationButton.frame = CGRect(x: buttonHeight * 0.05, y: buttonHeight * 0.05, width: buttonHeight * 0.9, height: buttonHeight * 0.9)
                 self.recordingAnimationButton.layer.backgroundColor = UIColor.white.cgColor
                 self.recordingAnimationButton.clipsToBounds = true
                 self.recordingAnimationButton.layer.cornerRadius = min(self.recordingAnimationButton.frame.width, self.recordingAnimationButton.frame.height) * 0.5
                 self.recordingAnimationButton.layer.borderWidth = 2
                 self.recordingAnimationButton.layer.borderColor = UIColor.darkGray.cgColor
                 self.recordingAnimationButton.alpha = 1.0
                 }, completion: nil)
         }
     }
    
    private func setupLabel(){
        resultLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height * 0.5))
        resultLabel.font = .systemFont(ofSize: 40,weight:.black)
        resultLabel.textAlignment = .center
        resultLabel.textColor = UIColor.white
        view.addSubview(resultLabel)
        view.bringSubviewToFront(resultLabel)
        resultLabel.text = "表情を\nうごかしてください"
        resultLabel.numberOfLines = 2
        
//        totalPointLabel = UILabel(frame: CGRect(x: view.bounds.maxX - 100, y: 0, width: 100, height: 100))
//        totalPointLabel.font = .systemFont(ofSize: 12,weight:.heavy)
//        totalPointLabel.textAlignment = .left
//        totalPointLabel.textColor = UIColor.darkGray
//        view.addSubview(totalPointLabel)
//        view.bringSubviewToFront(totalPointLabel)
//        totalPointLabel.text = "time:0"
//        totalPointLabel.numberOfLines = 3
    }
    
    var previewView = UIView()
    
    private func setupPreviewLayer() {
        previewView.frame = view.frame
        view.addSubview(previewView)
        self.cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
        self.cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        self.cameraPreviewLayer?.frame = previewView.frame
        self.previewView.layer.insertSublayer(self.cameraPreviewLayer!, at: 1)
    }
    
    //MARK: - GoodLooking
    private var requests = [VNRequest]()
    private var mlRequest = [VNRequest]()
    var currentBuffer:CVImageBuffer?
    private let session = AVCaptureSession()
    private var videoDeviceInput: AVCaptureDeviceInput!
    private let videoDataOutput = AVCaptureVideoDataOutput()
    private let videoDataOutputQueue = DispatchQueue(label: "VideoDataOutput", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
    var bufferSize: CGSize = .zero
    var objectBounds = CGRect.zero
    var isRequest = false
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if isRequest {
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
                return
            }
            currentBuffer = pixelBuffer
            
            let exifOrientation = exifOrientationFromDeviceOrientation()
            let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: exifOrientation, options: [:])
            do {
                try imageRequestHandler.perform(self.requests)
            } catch {
                print(error)
            }
            isRequest = false
        }
    }
    
    func mlCompletion(_ results: [Any])  {
        guard let observation = results.first as? VNClassificationObservation else {
            print("its not ml observation")
            return
        }
        print("capturing")
        if observation.identifier == "ikemen" {
            resultLabel.text = "イケメン\n\(floor(observation.confidence * 100))"
            playHapticsFile("DogHelloSmile")
            ikemenCount += 1
        } else {
            resultLabel.text = "イケメンではない\n\(floor(observation.confidence * 100))"
        }
    }
    
    func setupAVCapture() {
        
        // Select a video device, make an input
        let videoDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .front).devices.first
        do {
            videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice!)
        } catch {
            print("Could not create video device input: \(error)")
            return
        }
        
        session.beginConfiguration()
        session.sessionPreset = .vga640x480 // Model image size is smaller.
        
        // Add a video input
        guard session.canAddInput(videoDeviceInput) else {
            print("Could not add video device input to the session")
            session.commitConfiguration()
            return
        }
        session.addInput(videoDeviceInput)
        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
            // Add a video data output
            videoDataOutput.alwaysDiscardsLateVideoFrames = true
            videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
            videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
            
        } else {
            print("Could not add video data output to the session")
            session.commitConfiguration()
            return
        }
        
        let captureConnection = videoDataOutput.connection(with: .video)
        captureConnection?.videoOrientation = .portrait
        // Always process the frames
        captureConnection?.isEnabled = true
        do {
            try  videoDevice!.lockForConfiguration()
            let dimensions = CMVideoFormatDescriptionGetDimensions((videoDevice?.activeFormat.formatDescription)!)
            bufferSize.width = CGFloat(dimensions.height)
            bufferSize.height = CGFloat(dimensions.width)
            videoDevice!.unlockForConfiguration()
        } catch {
            print(error)
        }
        session.commitConfiguration()
        setupVision()
        
        // start the capture
        startCaptureSession()
    }
    
    func startCaptureSession() {
        session.startRunning()
    }
    
    public func exifOrientationFromDeviceOrientation() -> CGImagePropertyOrientation {
        let curDeviceOrientation = UIDevice.current.orientation
        let exifOrientation: CGImagePropertyOrientation
        
        switch curDeviceOrientation {
        case UIDeviceOrientation.portraitUpsideDown:  // Device oriented vertically, home button on the top
            exifOrientation = .left
        case UIDeviceOrientation.landscapeLeft:       // Device oriented horizontally, home button on the right
            exifOrientation = .upMirrored
        case UIDeviceOrientation.landscapeRight:      // Device oriented horizontally, home button on the left
            exifOrientation = .down
        case UIDeviceOrientation.portrait:            // Device oriented vertically, home button on the bottom
            exifOrientation = .up
        default:
            exifOrientation = .up
        }
        return exifOrientation
    }
    
    @discardableResult
    func setupVision() -> NSError? {
        // Setup Vision parts
        let error: NSError! = nil
        
        guard let modelURL = Bundle.main.url(forResource: "ikemenclasifier 1", withExtension: "mlmodelc") else {
            return NSError(domain: "VisionObjectRecognitionViewController", code: -1, userInfo: [NSLocalizedDescriptionKey: "Model file is missing"])
        }
        do {
            let visionModel = try VNCoreMLModel(for: MLModel(contentsOf: modelURL))
            let objectRecognition = VNCoreMLRequest(model: visionModel, completionHandler: { (request, error) in
                DispatchQueue.main.async(execute: {
                    // perform all the UI updates on the main queue
                    if let results = request.results {
                        self.mlCompletion(results)
                    }
                })
            })
            let faceCropRequest:VNDetectFaceRectanglesRequest = {
                let request = VNDetectFaceRectanglesRequest(completionHandler: { (request, error) in
                    DispatchQueue.main.async(execute: {
                        // perform all the UI updates on the main queue
                        if let results = request.results {
                            self.drawVisionRequestResults(results)
                        }
                    })
                })
                request.revision = VNDetectFaceRectanglesRequestRevision2
                return request
            }()
            
            self.requests = [faceCropRequest]
            self.mlRequest = [objectRecognition]
        } catch let error as NSError {
            print("Model loading went wrong: \(error)")
        }
        
        return error
    }
    
    func drawVisionRequestResults(_ results: [Any]) {
        for observation in results where observation is VNFaceObservation {
            guard let objectObservation = observation as? VNFaceObservation else {
                    print("かおが\nうつっていません")
                continue
            }
            
            objectBounds = VNImageRectForNormalizedRect(objectObservation.boundingBox, Int(bufferSize.width), Int(bufferSize.height))
            
        }
        if currentBuffer != nil {
            let image = CIImage(cvImageBuffer: currentBuffer!)
            currentBuffer = nil
            guard let observation = results.first as? VNFaceObservation else {
                return
            }
            let faceRect = VNImageRectForNormalizedRect(observation.boundingBox,Int(image.extent.size.width), Int(image.extent.size.height))
            let faceImage = image.cropped(to: faceRect)
            //            let context = CIContext()
            //            let final = context.createCGImage(faceImage, from: faceImage.extent)
            let mlRequestHandler = VNImageRequestHandler(ciImage: faceImage, options: [:])
            do {
                try mlRequestHandler.perform(self.mlRequest)
            } catch {
                print(error)
            }
        }
    }
    
    private var engine: CHHapticEngine!
        
       lazy var supportsHaptics: Bool = {
           let appDelegate = UIApplication.shared.delegate as! AppDelegate
           return appDelegate.supportsHaptics
       }()
       
        func createEngine() {
           if !supportsHaptics {return}
            do {
                engine = try CHHapticEngine()
            } catch let error {
                fatalError("Engine Creation Error: \(error)")
            }
            
            engine.stoppedHandler = { reason in
                print("Stop Handler: The engine stopped for reason: \(reason.rawValue)")
                switch reason {
                case .audioSessionInterrupt: print("Audio session interrupt")
                case .applicationSuspended: print("Application suspended")
                case .idleTimeout: print("Idle timeout")
                case .notifyWhenFinished: print("Finished")
                case .systemError: print("System error")
                @unknown default:
                    print("Unknown error")
                }
            }
            engine.resetHandler = {
                print("The engine reset --> Restarting now!")

            
            do {
               try self.engine.start()
            } catch let error {
                fatalError("Engine Start Error: \(error)")
            }
        }
           do {
                      try self.engine.start()
                   } catch let error {
                       fatalError("Engine Start Error: \(error)")
                   }
           }
        
       func playHapticsFile(_ filename: String){
           if !supportsHaptics { return }
                  
                  guard let path = Bundle.main.path(forResource: filename, ofType: "ahap") else { return }
           do {
               try engine.start()
               try engine.playPattern(from: URL(fileURLWithPath: path))
           } catch {
               print("haptics error")
           }
       }
}

extension UIView {
    var snapshot: UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}


