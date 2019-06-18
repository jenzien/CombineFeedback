//
//  ContentView.swift
//  ExampleApp
//
//f  Created by Jacob Enzien on 6/17/19.
//  Copyright © 2019 Jacob Enzien. All rights reserved.
//

import SwiftUI
import Combine

struct ContentView : View {
    @ObjectBinding var state = ContentSystem(initialCount: 0)
    var body: some View {
        VStack {
            Spacer()
            Button(action: self.state.increment.send) {
                Text("+")
            }
            Spacer()
            Text("\($state.state.value)")
            Spacer()
            Button(action: self.state.decrement.send) {
                Text("-")
            }
            Spacer()
        }
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
