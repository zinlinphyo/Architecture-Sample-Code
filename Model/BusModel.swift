//
//  BusModel.swift
//  Flymya
//
//  Created by Zin Lin Phyo on 19/11/2019.
//  Copyright © 2019 Flymya.com. All rights reserved.
//

import Foundation

class BusModel {

    enum SeatType : String {
        case WindowSeat = AppConstants.BusSeatType.WindowSeat
        case AisleSeat = AppConstants.BusSeatType.AisleSeat
        case Aisle = AppConstants.BusSeatType.Aisle
    }
    
    enum BusTraveller {
        case Male
        case Female
        case Mix
    }

    // MARK: - Attributes
    private(set) var busStationsList = [BusStation]()
    private(set) var busList = [Bus]()
    private(set) var selectedBus : Bus?
    private(set) var selectedSeatList: [BusSeat] = []
    
    var busCustomer: BusCustomerRequest?
    var selectedPaymentMethod: PaymentGateWay?
    
    /// Requests
    var busSearchRequest = BusSearchRequest()
    
    /// Responses
    var busSearchResponse : BusSearchResponse?
    private(set) var busSeatPlanResponse : BusSeatPlanResponse?
    private(set) var reservedSeatResponse : BusReservedSeatResponse?
    private(set) var busBookingResponse : BusBookingResponse?
    private(set) var createBookingResponse : BusCreateBookingResponse?
    private(set) var busUpdateBookingResponse : BusUpdateBookingResponse?
    private(set) var busDetailResponse : BusDetailResponse?
    var reservedSeatDetailResponse : BusReservedSeatDetailResponse?
    
    // MARK: - Init
    private init() {}
    
    class func shared() -> BusModel {
        return sharedDataModel
    }
    
    private static var sharedDataModel: BusModel = {
        let dataModel = BusModel()
        return dataModel
    }()
    
    // MARK: - Public Methods
    func setBusList(to busList: [Bus]) {
        self.busList.removeAll()
        self.busList = busList
    }
    
    func setSelectedBus(to bus : Bus) {
        self.selectedBus = bus
    }
    
    func setSelectedSeat(to seatList: [BusSeat]) {
        self.selectedSeatList.removeAll()
        self.selectedSeatList = seatList
    }
    
    func getPassengerCountText() -> String {
        let adultCount = busSearchRequest.passengerCount
        var text = ""
        if adultCount > 1 {
            text = "\(adultCount) Passengers"
        }
        else {
            text = "\(adultCount) Passenger"
        }
        
        return text
    }
    
    func clearBusSearchData() {
        busCustomer = nil
        selectedPaymentMethod = nil
        selectedBus = nil
        busList = []
        selectedSeatList = []
        busSearchRequest = BusSearchRequest()
        busSearchResponse = nil
        busSeatPlanResponse = nil
        reservedSeatResponse = nil
        busBookingResponse = nil
        createBookingResponse = nil
        busUpdateBookingResponse = nil
        busDetailResponse = nil
        reservedSeatDetailResponse = nil
    }
    
    // MARK: - Network Call
    
    /// To get bus stations list from API
    /// - Parameter success: success callback
    /// - Parameter failure: failure callback
    func getBusStations(success : @escaping () -> Void, failure : @escaping (String) -> Void) {
        if busStationsList.isEmpty {
            FlymyaDataAgent.shared().getBusLocation(success: { (data) in
                
                /// Sort popular destination first in list
                let popularDestination = ["yangon", "mandalay", "naypyitaw (myoma)", "naypyitaw (bawga)", "naypyitaw (thapyaygone)", "naypyitaw(toll gate)"]
                
                var popularDestinationList : [BusStation] = []
                
                for popularCity in popularDestination {
                    let item = data.filter { $0.locationNameEN?.lowercased() == popularCity }.first
                    if let city = item {
                        popularDestinationList.append(city)
                    }
                }
                
                let destinationList = data.filter { !popularDestination.contains($0.locationNameEN?.lowercased() ?? "")  }
                
                let sortedList : [BusStation] = popularDestinationList + destinationList
                
                self.busStationsList = sortedList
                
                success()
            }) { (error) in
                failure(error)
            }
        } else {
            success()
        }
    }
    
    /// To get bus list from API according to search criteria
    /// - Parameter success: success callback
    /// - Parameter failure: failure callback
    func getBusList(success : @escaping () -> Void, failure : @escaping (String) -> Void) {
        
        FlymyaDataAgent.shared().searchBusList(requestData: busSearchRequest, success: { (response) in
            self.busSearchResponse = response
            success()
        }) { (error) in
            failure(error)
        }
    }
    
    /// To get seat plan of selected bus from API
    /// - Parameter success: success callback
    /// - Parameter failure: failure callback
    func getSeatPlan(success : @escaping () -> Void, failure : @escaping (String) -> Void) {
        
        guard let bus = self.selectedBus else {
            failure("No selected bus.")
            return
        }
        
        guard let uuid = bus.uuid else {
            failure("No uuid in selected bus.")
            return
        }
        
        let requestData = BusSeatPlanRequest(uuid: uuid)
        
        FlymyaDataAgent.shared().getBusSeatPlan(requestData: requestData, success: { (response) in
            self.busSeatPlanResponse = response
            success()
        }) { (error) in
            failure(error)
        }
    }
    
    func reserveSeat(success : @escaping () -> Void, failure : @escaping (String) -> Void) {
        
        guard let bus = self.selectedBus else {
            failure("No selected bus.")
            return
        }
        
        guard let uuid = bus.uuid else {
            failure("No uuid in selected bus.")
            return
        }
        
        var seatIds: [BusSeatId] = []
        
        selectedSeatList.forEach { (seat) in
            guard let seatId = seat.seatId else {
                failure("SeatId is nil.")
                return
            }
            seatIds.append(BusSeatId(seatId: seatId))
        }
        
        let requestData = BusReserveSeatRequest(uuid: uuid, seatIds: seatIds)
        
        FlymyaDataAgent.shared().busReserveSeat(requestData: requestData, success: { (response) in
            
            self.reservedSeatResponse = response
            success()
            
        }) { (error) in
            failure(error)
        }
        
    }
    
    func reservedSeatDetail(success : @escaping () -> Void, failure : @escaping (String) -> Void) {
        guard let bus = self.selectedBus else {
            failure("No selected bus.")
            return
        }
        
        guard let uuid = bus.uuid else {
            failure("No uuid in selected bus.")
            return
        }
        
        let requestData = BusReservedSeatDetailRequest(uuid: uuid)
        
        FlymyaDataAgent.shared().busReservedSeatDetail(requestData: requestData, success: { (response) in
            
            self.reservedSeatDetailResponse = response
            success()
            
        }) { (error) in
            failure(error)
        }
    }
    
    func createBooking(customerInfo: BusCustomerRequest, success : @escaping () -> Void, failure : @escaping (String) -> Void) {
        self.busCustomer = customerInfo
        
        guard let uuid = selectedBus?.uuid else {
            failure("No uuid in selected bus.")
            return
        }
        
        guard let bookingCorrelationId = reservedSeatDetailResponse?.reservedSeat?.bookingCorrelationId else {
            failure("Correlation id is nil.")
            return
        }
        
        var requestData = BusCreateBookingRequest()
        requestData.uuid = uuid
        requestData.bookingCorrelationId = bookingCorrelationId
        requestData.paymentMethod = ""
        requestData.customer = customerInfo
        
        FlymyaDataAgent.shared().busCreateBooking(requestData: requestData, success: { (response) in
            self.createBookingResponse = response
            success()
        }) { (error) in
            failure(error)
        }
    }
    
    func updateBooking(success : @escaping () -> Void, failure : @escaping (String) -> Void) {
        
        let requestData = BusUpdateBookingRequest()
        
        FlymyaDataAgent.shared().busUpdateBooking(requestData: requestData, success: { (response) in
            self.busUpdateBookingResponse = response
            success()
        }) { (error) in
            failure(error)
        }
    }
    
    func getBusDetail(success : @escaping () -> Void, failure : @escaping (String) -> Void) {
        
        guard let bookingId = createBookingResponse?.bookingId else {
            failure("Booking ID is nil.")
            return
        }
                
        FlymyaDataAgent.shared().getBusDetail(bookingId: "\(bookingId)", success: { (response) in
            self.busDetailResponse = response
            success()
        }) { (error) in
            failure(error)
        }
    }
}
