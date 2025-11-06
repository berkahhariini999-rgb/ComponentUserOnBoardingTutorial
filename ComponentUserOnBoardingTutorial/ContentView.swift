//
//  ContentView.swift
//  ComponentUserOnBoardingTutorial
//
//  Created by Iqbal Alhadad on 06/11/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        OneTimeOnBoarding(appStorageID:"Home_Tutorial") {
            VStack {
                VStack {
                   Text("Hello")
                }
            
            .padding()
            .onBoarding(1){
                
            }
            Button("Download") {
                
            }
            .padding(15)
            .onBoarding(2){
                
            }
        }
    } beginOnboarding: {
        
    } onBoardingFinished: {
        
    }
 }
}

#Preview {
    ContentView()
}
