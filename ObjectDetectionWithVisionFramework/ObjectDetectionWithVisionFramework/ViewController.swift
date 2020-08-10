//
//  ViewController.swift
//  ObjectDetectionWithVisionFramework
//
//  Created by prasu on 10/08/20.
//  Copyright © 2020 prasanna. All rights reserved.
//

import UIKit
import AVKit
import Vision

class ViewController: UIViewController,AVCaptureVideoDataOutputSampleBufferDelegate {
    @IBOutlet weak var objectNameLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    let captureSession = AVCaptureSession()
            captureSession.sessionPreset = .photo
            guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
            guard let input = try? AVCaptureDeviceInput.init(device: captureDevice) else {return}
            captureSession.addInput(input)
            captureSession.startRunning()
            let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.frame = view.frame
            view.layer.addSublayer(previewLayer)
        
            let dataOutput = AVCaptureVideoDataOutput()
            dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoOutputString"))
            captureSession.addOutput(dataOutput)
        }

        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
            guard let model = try? VNCoreMLModel(for: SqueezeNet().model) else {
                return
            }

            let request = VNCoreMLRequest(model: model) { (finishedRequest, _) in
                guard let results = finishedRequest.results as? [VNClassificationObservation] else { return }
                guard let firstObservation = results.first else { return }

                DispatchQueue.main.async {
                    self.objectNameLabel.text = firstObservation.identifier
                }
            }

            try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
        }


}

