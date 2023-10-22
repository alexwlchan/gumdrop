//
//  ContentView.swift
//  gumdrop
//
//  Created by Alex Chan on 22/10/2023.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel = ContentViewModel()
    
    init() {
        viewModel.checkAuthorization()
    }

    var body: some View {
        GeometryReader { geometry in
            HStack {
                Spacer()
                
                VStack {
                    Spacer(minLength: geometry.size.height * 0.15)
                    
                    PlayerContainerView(captureSession: viewModel.captureSession)
                        .cornerRadius(5)
                        .aspectRatio(CGSize(width: 4, height: 3), contentMode: .fit)
                    
                    Spacer(minLength: geometry.size.height * 0.15)
                }
                
                Spacer()
            }
        }
    }
}
