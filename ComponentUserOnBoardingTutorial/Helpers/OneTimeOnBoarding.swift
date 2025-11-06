//
//  OneTimeOnBoarding.swift
//  ComponentUserOnBoardingTutorial
//
//  Created by Iqbal Alhadad on 06/11/25.
//

import SwiftUI

fileprivate struct OnBoardingItem: Identifiable {
    var id: Int
    var view: AnyView
    var maskLocation: CGRect
}

@Observable
fileprivate class OnBoardingCoordinator {
    var items: [OnBoardingItem] = []
    var overlayWindow: UIWindow?
    
    // ordered items
    var orderedItem: [OnBoardingItem] {
        items.sorted {
            $0.id < $1.id
        }
    }
}


struct OneTimeOnBoarding<Content: View>: View {
    @AppStorage var isOnBoarded: Bool
    var content:Content
    //allow animate onboarding effect
    var beginOnboarding: () async -> Void
    var onBoardingFinished: () -> Void
    
    init(
        appStorageID: String,
       @ViewBuilder content: @escaping() -> Content,
        beginOnboarding: @escaping () async -> Void,
        onBoardingFinished: @escaping () -> Void
    ) {
        //initializing user default
        self._isOnBoarded = .init(wrappedValue: false, appStorageID)
        self.content = content()
        self.beginOnboarding = beginOnboarding
        self.onBoardingFinished = onBoardingFinished
    }
    
    fileprivate var coordinator = OnBoardingCoordinator()
    var body: some View {
        content
            .environment(coordinator)
            .task {
                await beginOnboarding()
                await createWindow()
            }
    }
    
    private func createWindow() async {
        if let scene = (UIApplication.shared.connectedScenes.first as? UIWindowScene),
           !isOnBoarded, coordinator.overlayWindow == nil {
            let window = UIWindow(windowScene: scene)
            window.backgroundColor = .clear
            window.isHidden = false
            window.isUserInteractionEnabled = true
            
            coordinator.overlayWindow = window
            //little delay load items into coordinator object using onGeometryChange modifier
            try? await Task.sleep(for: .seconds(0.1))
            if coordinator.items.isEmpty {
                hideWindow()
            } else {
                //snapshot window and animate it
                
                
            }
        }
    }
        private func hideWindow() {
            coordinator.overlayWindow?.isHidden = true
            coordinator.overlayWindow?.isUserInteractionEnabled = false
        }
    }
    


extension View {
    //u can pass custom shape for each onboarding item as well
    @ViewBuilder
    func onBoarding<Content: View>(_ position: Int, @ViewBuilder content: @escaping () -> Content) -> some View {
        self
            .modifier(OnBoardingItemSetter(position: position, onBoardingContent: content))
    }
}

//onboarding item setter
fileprivate struct OnBoardingItemSetter<OnBoardingContent: View>: ViewModifier {
    var position: Int
    @ViewBuilder var onBoardingContent: OnBoardingContent
    
    @Environment(OnBoardingCoordinator.self) var coordinator
    func body(content: Content) -> some View {
        content
        //adding or removing item coordinator object
            .onGeometryChange(for: CGRect.self) {
                $0.frame(in: .global)
                
            } action: { newValue in
                coordinator.items.removeAll(where: {
                    $0.id == position
                })
                
                let newItem = OnBoardingItem(id: position,
                                             view: .init(onBoardingContent), maskLocation: newValue)
                coordinator.items.append(newItem)
            }
            .onDisappear{
                coordinator.items.removeAll(where: {
                    $0.id == position
                })
            }
    }
}

#Preview {
    ContentView()
}
