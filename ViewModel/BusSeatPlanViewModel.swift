//
//  BusSeatPlanViewModel.swift
//  Flymya
//
//  Created by Zin Lin Phyo on 25/11/2019.
//  Copyright © 2019 Flymya.com. All rights reserved.
//

import Foundation

struct BusSeatPlanViewModel {
    
    private(set) var busName = ""
    private(set) var passengerCount = ""
    private(set) var busRoute = ""
    private(set) var rowCount : Int = 0
    private(set) var columnCount : Int = 0
    private(set) var levelCount : Int = 0
    private(set) var seatNumbers: String = ""
    
    private(set) var busSeatList : [[BusSeat]] = []
    
    var selectedSeatList: [BusSeat] = []
    
    init() {
        busName = BusModel.shared().selectedBus?.operatorNameEN ?? ""
        busRoute = (BusModel.shared().selectedBus?.routeNameEN ?? "") + ", "
        if BusModel.shared().busSearchRequest.passengerCount > 1 {
            passengerCount = BusModel.shared().busSearchRequest.passengerCount.stringValue + " Passengers"
        } else {
            passengerCount = "1 Passenger"
        }
        
        seatNumbers = ""
    }
    
    mutating func updateSeatList() {
        guard let busDetail = BusModel.shared().busSeatPlanResponse?.busDetail else {
            return
        }
        
        var originSeatList = busDetail.seatList ?? []
        originSeatList = originSeatList.sorted(by: { $0.row! < $1.row! })
        
        sortingSeatList(to: originSeatList)
    }
    
    private mutating func sortingSeatList(to originSeatList: [BusSeat]) {
        
        busSeatList.removeAll()
        
        guard let busDetail = BusModel.shared().busSeatPlanResponse?.busDetail else {
            return
        }
        
        rowCount = busDetail.busType?.numOfRow ?? 0
        columnCount = busDetail.busType?.numOfColumn ?? 0
        levelCount = busDetail.busType?.numOfLevel ?? 0
        
        for rowNumber in 1...rowCount {
            var rowSeatList = originSeatList.filter({ $0.row == rowNumber })
            rowSeatList = rowSeatList.sorted(by: { $0.column! < $1.column!  })
            if !rowSeatList.isEmpty {
                busSeatList.append(rowSeatList)
            }
        }
    }
    
    mutating func didSelectSeat(to index: IndexPath, deselectAt : @escaping (IndexPath) -> Void) {
        
        let result = selectedSeatList.filter({ $0.seatId == busSeatList[index.section][index.row].seatId })
        
        if !result.isEmpty {
            selectedSeatList = selectedSeatList.filter({ $0.seatId != busSeatList[index.section][index.row].seatId })
        } else {
            if selectedSeatList.count < BusModel.shared().busSearchRequest.passengerCount {
                selectedSeatList.append(busSeatList[index.section][index.row])
            } else {
                selectedSeatList.removeFirst()
                selectedSeatList.append(busSeatList[index.section][index.row])
            }
        }
        
//        selectedSeatList = selectedSeatList.sorted(by: { Int($0.seatId!)! > Int($1.seatId!)! })
        
        seatNumbers = ""
        selectedSeatList.forEach { (seat) in
            seatNumbers += " \(seat.seatNo ?? ""),"
        }
        seatNumbers = String(seatNumbers.dropFirst())
        seatNumbers = String(seatNumbers.dropLast())
        
        print(selectedSeatList.map({ $0.seatNo }))
        
        BusModel.shared().setSelectedSeat(to: selectedSeatList)
    }
    
    func isSelectedSeat(for index: IndexPath) -> Bool {
        let result = selectedSeatList.filter({ $0.seatId == busSeatList[index.section][index.row].seatId })
        
        if !result.isEmpty {
            return true
        } else {
            return false
        }
    }
    
    func isSelectedAllSeat() -> Bool {
        if selectedSeatList.count == BusModel.shared().busSearchRequest.passengerCount {
            return true
        } else {
            return false
        }
    }
    
}

//struct Queue {
//
//    var items:[String] = []
//
//    mutating func enqueue(element: String)
//    {
//        items.append(element)
//    }
//
//    mutating func dequeue() -> String?
//    {
//
//        if items.isEmpty {
//            return nil
//        }
//        else{
//            let tempElement = items.first
//            items.remove(at: 0)
//            return tempElement
//        }
//    }
//
//}
