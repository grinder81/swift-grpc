//
//  ContentView.swift
//  grpc_client
//
//  Created by MD AL Mamun on 2020-03-24.
//  Copyright © 2020 MD AL Mamun. All rights reserved.
//

import SwiftUI
import Combine

struct ContentView: View {
    
    let api: RouteGuideType
    
    init(api: RouteGuideType) {
        self.api = api
    }
    
    var body: some View {
        var store = Set<AnyCancellable>()
        return VStack {
            Button("Connect") {
                self.api.connect { (group) in
                    return makeClient(port: 53532, group: group)
                }
            }
            
            Button("Fetch") {
                self.api.fetchFeature(latitude: 409146138, longitude: -746188906)
                    .replaceError(with: .init())
                    .sink(receiveValue: { (feature) in
                        print(feature)
                    })
                    .store(in: &store)
            }

            Button("Disconnect") {
                self.api.disconnect()
            }
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
