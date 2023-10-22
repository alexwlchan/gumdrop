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
        PlayerContainerView(captureSession: viewModel.captureSession)
           .clipShape(Circle())
    }
}
