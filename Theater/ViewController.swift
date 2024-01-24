//
//  ViewController.swift
//  Theater
//
//  Created by SangRae Kim on 1/15/24.
//

import UIKit
import MapKit
import CoreLocation

// 도봉캠: 위도 : 37.654406799999386, 경도 : 127.04561145393475

class ViewController: UIViewController {
    @IBOutlet var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    let theaters = TheaterList.mapAnnotations
    let defaultCoordinate = CLLocationCoordinate2D(latitude: 37.654406799999386, longitude: 127.04561145393475)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        
        designNavigationItem()
        setTheaterPoint(theaters: theaters)
        checkDeviceLocationAuthorization()
    }
}

// 디바이스 위치 서비스 설정 확인 및 사용자 권한 상태 확인
extension ViewController {
    func checkDeviceLocationAuthorization() {
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                let authorization: CLAuthorizationStatus
                
                if #available(iOS 14.0, *) {
                    authorization = self.locationManager.authorizationStatus
                } else {
                    authorization = CLLocationManager().authorizationStatus
                }
                
                DispatchQueue.main.async {
                    self.checkCurrentLocationAuthorization(authorization: authorization)
                }
                
            } else {
                print("아이폰의 위치 서비스가 꺼져있어서 아무것도 못합니다요")
            }
        }
    }
    
    func checkCurrentLocationAuthorization(authorization: CLAuthorizationStatus) {
        switch authorization {
        case .notDetermined:
            print("notDetermined")
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
        case .denied:
            print("denied")
            setRegionAndAnnotation(coordinate: defaultCoordinate, meter: 400)
            showLocationSettingAlert()
        case .authorizedWhenInUse:
            print("authorizedWhenInUse")
            locationManager.startUpdatingLocation()
        default:
            print("예상 못한 권한 상태!")
        }
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coordinate = locations.last?.coordinate {
            print(coordinate)
            setRegionAndAnnotation(coordinate: coordinate, meter: 20000)
        }
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkDeviceLocationAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkDeviceLocationAuthorization()
    }
}

extension ViewController {
    func showLocationSettingAlert() {
        let alert = UIAlertController(title: "위치 정보 이용", message: "위치 서비스를 사용할 수 없습니다. 기기의 '설정>개인정보 보호'에서 위치 서비스를 켜주세요.", preferredStyle: .alert)
        let settingButton = UIAlertAction(title: "설정으로 이동", style: .default) { _ in
            if let settingURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingURL)
            } else {
                print("설정으로 이동이 실패하였습니다.")
            }
        }
        let cancelButton = UIAlertAction(title: "취소", style: .cancel)
        
        alert.addAction(settingButton)
        alert.addAction(cancelButton)
        
        present(alert, animated: true)
    }
    
    func setRegionAndAnnotation(coordinate: CLLocationCoordinate2D, meter: CLLocationDistance) {
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: meter, longitudinalMeters: meter)
        
        mapView.setRegion(region, animated: true)
    }
    
    func setTheaterPoint(theaters: [Theater]) {
        let mid = CLLocationCoordinate2D(latitude: 37.50463962366038, longitude: 126.95485040796515)
        setRegionAndAnnotation(coordinate: mid, meter: 25000)
        
        for theater in theaters {
            let annotation = MKPointAnnotation()
            let coordinate = CLLocationCoordinate2D(latitude: theater.latitude, longitude: theater.longitude)
            annotation.coordinate = coordinate
            annotation.title = theater.location
            
            mapView.addAnnotation(annotation)
        }
    }
    
    func designNavigationItem() {
        let rightBarButton = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(rightBarButtonItemClicked))
        navigationItem.title = "영화관 탐색"
        navigationItem.rightBarButtonItem = rightBarButton
    }
    
    @objc func rightBarButtonItemClicked() {
        mapView.removeAnnotations(mapView.annotations)
        
        let action = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let lotte = UIAlertAction(title: "롯데시네마", style: .default) { _ in
            self.setTheaterPoint(theaters: Types.lotte.returnList)
        }
        let mega = UIAlertAction(title: "메가박스", style: .default) { _ in
            self.setTheaterPoint(theaters: Types.mega.returnList)
        }
        let cgv = UIAlertAction(title: "CGV", style: .default) { _ in
            self.setTheaterPoint(theaters: Types.cgv.returnList)
        }
        let all = UIAlertAction(title: "전체보기", style: .default) { _ in
            self.setTheaterPoint(theaters: Types.all.returnList)
        }
        
        action.addAction(lotte)
        action.addAction(mega)
        action.addAction(cgv)
        action.addAction(all)
        
        present(action, animated: true)
    }
}
