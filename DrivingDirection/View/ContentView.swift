//
//  ContentView.swift
//  DrivingDirection
//
//  Created by 沈清昊 on 5/15/23.
//

import SwiftUI

struct ContentView: View {
    @State var origin = ""
    @State var destination = ""
    
    @StateObject var locationManager = LocationManager()
    
    var body: some View {
        NavigationView{
            VStack{
                TextField("Source location", text: $origin)
                    .frame(width: 400, height: 50)
                    .background(Color.gray.opacity(0.3).cornerRadius(20))
                    .padding(10)
                TextField("Destination location", text: $destination)
                    .frame(width: 400, height: 50)
                    .background(Color.gray.opacity(0.3).cornerRadius(20))
                    .padding(10)
                NavigationLink("Drive Direction") {
                    DirectionView(vm: DirectionViewModel(origin: origin, dest: destination))
                }
                Divider()
                NavigationLink("Use your current location"){
                    DirectionView(vm: DirectionViewModel(origin: "\((locationManager.manager.location?.coordinate.latitude)!), \((locationManager.manager.location?.coordinate.longitude)!)", dest: destination))
                }
            }
            .navigationTitle("Driving direction")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
