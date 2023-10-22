//
//  ContentView.swift
//  gumdrop
//
//  Created by Alex Chan on 22/10/2023.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel = ContentViewModel()
    
    @State private var bgColor =
        Color(.sRGB, red: 0.98, green: 0.9, blue: 0.2)
    
    init() {
        viewModel.checkAuthorization()
    }

    var body: some View {
        GeometryReader { geometry in
            bgColor
                .ignoresSafeArea()
                .overlay {
                    HStack {
                        Spacer()
                        
                        VStack {
                            Spacer(minLength: geometry.size.height * 0.1)
                            
                            PlayerContainerView(captureSession: viewModel.captureSession)
                                .cornerRadius(5)
                                .aspectRatio(CGSize(width: 4, height: 3), contentMode: .fit)
                            
                            HStack {
                                Spacer()
                                
                                EmbeddedColorWell(selectedColor: $bgColor)
                                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)
                                    .frame(width: 80, height: 35)
                                
                                Button {
                                    viewModel.takePicture()
                                } label: {
                                    Image(systemName: "camera.fill")
                                }
                                    .controlSize(.large)
                                
                                Spacer()
                            }
                            
                            
                            Spacer(minLength: geometry.size.height * 0.1)
                        }
                        
                        Spacer()
                    }
                }
        }
    }
}
