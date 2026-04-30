import SwiftUI
import MapKit

// MARK: - Annotation model
final class AircraftAnnotation: NSObject, MKAnnotation {
    var aircraft: Aircraft
    @objc dynamic var coordinate: CLLocationCoordinate2D

    init(aircraft: Aircraft) {
        self.aircraft = aircraft
        self.coordinate = aircraft.coordinate
    }

    var title: String? { aircraft.displayCallsign }
    var subtitle: String? {
        guard let alt = aircraft.altitudeFeet, let spd = aircraft.speedKnots else { return nil }
        return "\(alt) ft · \(spd) kt"
    }

    func update(with newAircraft: Aircraft) {
        aircraft = newAircraft
        coordinate = newAircraft.coordinate
    }
}

// MARK: - Annotation view
final class AircraftAnnotationView: MKAnnotationView {
    static let reuseID = "AircraftAnnotationView"

    private let iconView = UIImageView()
    private let labelView = UILabel()

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        frame = CGRect(x: 0, y: 0, width: 36, height: 36)
        centerOffset = CGPoint(x: 0, y: 0)
        canShowCallout = false
        backgroundColor = .clear

        iconView.frame = CGRect(x: 4, y: 4, width: 28, height: 28)
        iconView.contentMode = .scaleAspectFit
        addSubview(iconView)

        labelView.font = .systemFont(ofSize: 9, weight: .semibold)
        labelView.textAlignment = .center
        labelView.textColor = .white
        labelView.backgroundColor = UIColor.black.withAlphaComponent(0.55)
        labelView.layer.cornerRadius = 3
        labelView.layer.masksToBounds = true
        labelView.frame = CGRect(x: -14, y: 30, width: 64, height: 12)
        addSubview(labelView)
    }

    func configure(with aircraft: Aircraft, selected: Bool) {
        let cfg = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        let img = UIImage(systemName: "airplane", withConfiguration: cfg)
        iconView.image = img
        iconView.tintColor = selected ? .systemOrange : aircraft.altitudeCategoryColor

        // Rotate: airplane SF Symbol points east; heading 0 = north
        let radians = (aircraft.heading ?? 0) * .pi / 180 - .pi / 2
        iconView.transform = CGAffineTransform(rotationAngle: radians)

        // Scale up selected
        transform = selected
            ? CGAffineTransform(scaleX: 1.5, y: 1.5)
            : .identity

        labelView.text = aircraft.displayCallsign
        labelView.isHidden = selected
    }
}

// MARK: - SwiftUI wrapper
struct RadarMapView: UIViewRepresentable {
    let aircraft: [Aircraft]
    @Binding var selectedAircraft: Aircraft?
    let mapType: MKMapType

    private static let sydneyAirport = CLLocationCoordinate2D(latitude: -33.9461, longitude: 151.1772)

    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.delegate = context.coordinator
        map.mapType = mapType
        map.showsUserLocation = true
        map.showsCompass = true
        map.showsScale = true

        let region = MKCoordinateRegion(
            center: Self.sydneyAirport,
            latitudinalMeters: 250_000,
            longitudinalMeters: 250_000
        )
        map.setRegion(region, animated: false)
        map.register(AircraftAnnotationView.self, forAnnotationViewWithReuseIdentifier: AircraftAnnotationView.reuseID)

        // Sydney Airport pin
        let airportPin = MKPointAnnotation()
        airportPin.coordinate = Self.sydneyAirport
        airportPin.title = "Sydney Airport (YSSY)"
        map.addAnnotation(airportPin)

        return map
    }

    func updateUIView(_ map: MKMapView, context: Context) {
        map.mapType = mapType
        syncAnnotations(on: map)
        updateSelection(on: map)
    }

    private func syncAnnotations(on map: MKMapView) {
        let existing = map.annotations.compactMap { $0 as? AircraftAnnotation }
        let existingMap = Dictionary(uniqueKeysWithValues: existing.map { ($0.aircraft.id, $0) })
        let newMap     = Dictionary(uniqueKeysWithValues: aircraft.map { ($0.id, $0) })

        // Remove stale
        let toRemove = existing.filter { newMap[$0.aircraft.id] == nil }
        map.removeAnnotations(toRemove)

        // Update or add
        for ac in aircraft {
            if let ann = existingMap[ac.id] {
                ann.update(with: ac)
                if let view = map.view(for: ann) as? AircraftAnnotationView {
                    let selected = selectedAircraft?.id == ac.id
                    view.configure(with: ac, selected: selected)
                }
            } else {
                map.addAnnotation(AircraftAnnotation(aircraft: ac))
            }
        }
    }

    private func updateSelection(on map: MKMapView) {
        for annotation in map.annotations {
            guard let ann = annotation as? AircraftAnnotation else { continue }
            if let view = map.view(for: ann) as? AircraftAnnotationView {
                view.configure(with: ann.aircraft, selected: ann.aircraft.id == selectedAircraft?.id)
            }
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, MKMapViewDelegate {
        var parent: RadarMapView

        init(_ parent: RadarMapView) { self.parent = parent }

        func mapView(_ map: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let aircraftAnn = annotation as? AircraftAnnotation else { return nil }
            let view = map.dequeueReusableAnnotationView(
                withIdentifier: AircraftAnnotationView.reuseID,
                for: aircraftAnn
            ) as! AircraftAnnotationView
            let selected = parent.selectedAircraft?.id == aircraftAnn.aircraft.id
            view.configure(with: aircraftAnn.aircraft, selected: selected)
            return view
        }

        func mapView(_ map: MKMapView, didSelect view: MKAnnotationView) {
            guard let ann = view.annotation as? AircraftAnnotation else { return }
            map.deselectAnnotation(ann, animated: false)
            withAnimation(.spring(response: 0.35)) {
                parent.selectedAircraft = ann.aircraft
            }
        }

        func mapView(_ map: MKMapView, didDeselect view: MKAnnotationView) {}

        // Tap on empty map → deselect
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            if gesture.state == .ended {
                withAnimation { parent.selectedAircraft = nil }
            }
        }
    }
}
