//
//  ContentView.swift
//  VisionApp
//
//  Created by Andrew on 12.11.2023.
//

import SwiftUI
import Vision

struct ContentView: View{
    @State private var peopleCount: Int = 0
    @State private var detectedRectangles: [CGRect] = []
  private  var image: String = "400345"
 @State private var detectWholeBody: Bool = false
    private var scaleFactor: Int = 2
    private let isCameraFeed: Bool = true
    var body: some View{
        if (!isCameraFeed){
            VStack{
                ZStack{
                    Image(uiImage: UIImage(named: image)!)
                        .resizable()
                        .scaledToFit()
                        .overlay(
                            ForEach(detectedRectangles.indices, id: \.self){index in
                                GeometryReader{ geometry in
                                    Rectangle()
                                        .path(in: CGRect(
                                            x: detectedRectangles[index].minX*geometry.size.width, y:detectedRectangles[index].minY*geometry.size.height/CGFloat(scaleFactor), width: detectedRectangles[index].width*geometry.size.width, height: detectedRectangles[index].height*geometry.size.height
                                        )
                                        )
                                        .stroke(Color.red,lineWidth: 2.0 )
                                }
                            }
                        )
                }
                VStack{
                    Toggle("Detect whole human", isOn: $detectWholeBody)
                        .padding().onChange(of: detectWholeBody){value in
                            countPeople()
                        }
                    
                }
                Text("People count: \(peopleCount)")
                    .font(.title)
                    .padding()
            }
            .onAppear{
                countPeople()
            }
        } else {
            HumanDetectionInCameraFeed()
        }
    }
    
    
    func countPeople(){
        guard let image = UIImage(named: image) else {return}
        
        guard let ciimage = CIImage(image: image) else {return}
        
        
        
        
        let request = VNDetectHumanRectanglesRequest{ request, error in
            if let error = error {
                print ("Error: \(error.localizedDescription)")
                return
            }
            guard let observations = request.results as? [VNHumanObservation] else {
                return
            }
            DispatchQueue.main.async {
                peopleCount = observations.count
                detectedRectangles = observations.map{
                    $0.boundingBox
                }
            }
        }
        
        #if targetEnvironment(simulator)
        request.usesCPUOnly = true
        #endif
        
        
        if (detectWholeBody){
            request.upperBodyOnly = false
        } else {
            request.upperBodyOnly = true
        }
        let handler = VNImageRequestHandler(ciImage: ciimage, options: [:])
        
        
        do{
            try handler.perform([request])
        } catch {
            print("Error:\(error.localizedDescription)")
        }
        
        
    }
    
    
    
}



#Preview {
    ContentView()
}
