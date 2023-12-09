//
//  HumanDetectionCameraFeed.swift
//  VisionApp
//
//  Created by Andrew on 09.12.2023.
//

import SwiftUI
import Vision
import AVKit
import AVFoundation




struct HumanDetectionInCameraFeed: View{
    let captureSession = AVCaptureSession()
    let captureSessionQueue = DispatchQueue(label: "captureSessionQueue")
    @ObservedObject var captureDelegate = CaptureDelegate()
    
    var body: some View{
        ZStack{
            VideoPreviewView(session: captureSession)
                .overlay(
                    ForEach(captureDelegate.detectedRectangles.indices, id: \.self){index in
                        GeometryReader{ geometry in
                            Rectangle()
                                .path(in: CGRect(
                                    x: captureDelegate.detectedRectangles[index].minY*geometry.size.height, y: captureDelegate.detectedRectangles[index].minX*geometry.size.width, width: captureDelegate.detectedRectangles[index].height*geometry.size.height, height: captureDelegate.detectedRectangles[index].width*geometry.size.width
                                )
                            )
                                .stroke(Color.red,lineWidth: 2.0 )
                        }
                    }
                )
        }.aspectRatio(contentMode: .fit)
        
        Text("Human count: \(captureDelegate.peopleCount)")
            .font(.title).padding()
            .onAppear{
                setupCaptureSession()
            }
            .onDisappear{
                captureSession.stopRunning()
            }
    }
    
    
    func setupCaptureSession(){
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("Failed to create device")
            return
        }
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            print("Failed to create AVCaptureDeviceInput")
            return
        }
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(captureDelegate, queue: captureSessionQueue)
        
        captureSession.beginConfiguration()
        
        if captureSession.canAddInput(videoDeviceInput){
            captureSession.addInput(videoDeviceInput)
        }
        
        if captureSession.canAddOutput(videoOutput){
            captureSession.addOutput(videoOutput)
        }
        
        captureSession.commitConfiguration()
        DispatchQueue.global().async {
            captureSession.startRunning()
        }
    }
    
}

struct VideoPreviewView: UIViewRepresentable{
    let session: AVCaptureSession
    
    
    
    func makeUIView(context: Context) -> some UIView {
        let view = UIView(frame: .zero)
        
        
        let previewlayer = AVCaptureVideoPreviewLayer(session: session)
        previewlayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewlayer)
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        DispatchQueue.main.async{
            if let previewlayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer{
                previewlayer.frame = uiView.bounds
            }
        }
        
        
        
    }
    
    
    
    
    
    
    
}
