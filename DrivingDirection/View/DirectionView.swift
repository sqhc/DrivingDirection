//
//  DirectionView.swift
//  DrivingDirection
//
//  Created by 沈清昊 on 5/15/23.
//

import SwiftUI
import MapKit

struct DirectionView: View {
    @StateObject var vm: DirectionViewModel
    
    var body: some View {
        ZStack{
            if let direction = vm.drivingDirection?.data{
                VStack{
                    mapView(origin: direction.origin!, destination: direction.destination!)
                        .frame(width: 400, height: 100)
                    
                    if let routes = direction.best_routes{
                        Section {
                            List(routes, id: \.route_name){ route in
                                VStack{
                                    Text(route.route_name ?? "")
                                    Text("Distance: \(route.distance_label ?? "")")
                                    Text("Duration: \(route.duration_label ?? "")")
                                    Text("Departure: \(route.departure_datetime_utc ?? "")")
                                    Text("Arrival: \(route.arrival_datetime_utc ?? "")")
                                }
                            }
                            .listStyle(.plain)
                        } header: {
                            Text("Routes")
                        }
                    }
                }
                .navigationTitle("Direction")
            }
            else{
                ProgressView()
            }
        }
        //.onAppear(perform: vm.fetchDirection)
        .onAppear(perform: vm.fetchDirectionFromLocal)
        .alert(isPresented: $vm.hasError, error: vm.error) {
            Button {
                
            } label: {
                Text("Cancel")
            }

        }
    }
}

struct DirectionView_Previews: PreviewProvider {
    static var previews: some View {
        DirectionView(vm: DirectionViewModel(origin: "", dest: ""))
    }
}

struct mapView: UIViewRepresentable{
    let origin: LocationData
    let destination: LocationData
    
    func makeCoordinator() -> Coordinator {
        return mapView.Coordinator()
    }
    
    func updateUIView(_ uiView: MKMapView, context: UIViewRepresentableContext<mapView>) {
        
    }
    
    func makeUIView(context: UIViewRepresentableContext<mapView>) -> MKMapView {
        let map = MKMapView()
        
        let originCorrdinate = CLLocationCoordinate2D(latitude: origin.latitude ?? 0.0, longitude: origin.longitude ?? 0.0)
        
        let destinationCorrdinate = CLLocationCoordinate2D(latitude: destination.latitude ?? 0.0, longitude: destination.longitude ?? 0.0)
        
        let originPin = MKPointAnnotation()
        originPin.coordinate = originCorrdinate
        originPin.title = origin.full_address
        
        let destPin = MKPointAnnotation()
        destPin.coordinate = destinationCorrdinate
        destPin.title = destination.full_address
        
        map.addAnnotation(originPin)
        map.addAnnotation(destPin)
        
        let region = MKCoordinateRegion(center: originCorrdinate, latitudinalMeters: 100000, longitudinalMeters: 100000)
        map.region = region
        
        map.delegate = context.coordinator
        
        let req = MKDirections.Request()
        req.source = MKMapItem(placemark: MKPlacemark(coordinate: originCorrdinate))
        req.destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationCorrdinate))
        
        let directions = MKDirections(request: req)
        directions.calculate { direct, error in
            if error != nil{
                print((error?.localizedDescription)!)
                return
            }
            
            let polyLine = direct?.routes.first?.polyline
            map.addOverlay(polyLine!)
            map.setRegion(MKCoordinateRegion(polyLine!.boundingMapRect), animated: true)
        }
        
        return map
    }
    
    class Coordinator : NSObject, MKMapViewDelegate{
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let render = MKPolylineRenderer(overlay: overlay)
            render.strokeColor = .blue
            render.lineWidth = 2
            return render
        }
    }
}
