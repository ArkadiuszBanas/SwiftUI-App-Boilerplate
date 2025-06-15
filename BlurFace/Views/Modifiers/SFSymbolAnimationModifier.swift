import SwiftUI

struct SFSymbolAnimationModifier: ViewModifier {

    @State var isAnimating = false

    func body(content: Content) -> some View {
        content
            .symbolEffect(.bounce, options: .repeating.speed(0.25), value: isAnimating)
            .onAppear() {
                self.isAnimating = true
            }
    }
}

extension View {
    func sfSymbolAnimation() -> some View {
        modifier(SFSymbolAnimationModifier())
    }
} 
