//
//  CaptureDelegate.swift
//  VisionApp
//
//  Created by Andrew on 09.12.2023.
//

import Foundation
import AVFoundation
import Vision





class CaptureDelegate: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, ObservableObject{
    @Published var peopleCount: Int = 0
    @Published var detectedRectangles : [CGRect] = []
    
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        let request = VNDetectHumanRectanglesRequest { request, error in
            if let error = error{
                print ("Error:\(error.localizedDescription)")
                return
            }
            guard let observations = request.results as? [VNHumanObservation] else {
                return
            }
        
        DispatchQueue.main.async{ [self] in
            self.peopleCount = observations.count
            self.detectedRectangles = observations.map{
                $0.boundingBox
            }
            
            print("Count: \(peopleCount)")
        }
        
    }
        request.upperBodyOnly = false
        
        
        do {
            try VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
        } catch {
            print("Error: \(error.localizedDescription)")
        }
        
        
}
}
