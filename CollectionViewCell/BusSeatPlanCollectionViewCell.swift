//
//  BusSeatPlanCollectionViewCell.swift
//  Flymya
//
//  Created by Zin Lin Phyo on 02/12/2019.
//  Copyright © 2019 Flymya.com. All rights reserved.
//

import UIKit

class BusSeatPlanCollectionViewCell: UICollectionViewCell {
    
    lazy var ivSeat: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "bus_available_seat")
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    lazy var lblSeatNumber : UILabel = {
        let lbl = UILabel()
        lbl.textColor = .white
        lbl.font = UIFont(name: AppConstants.Font.Roboto.Medium, size: 14)
        lbl.text = ""
        return lbl
    }()
    
    private var seat : BusSeat?
    private var isSelectedSeat: Bool = false
    
    var didSelectSeatHandler : () -> Void = {}
    
    //MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        self.addSubview(ivSeat)
        self.addSubview(lblSeatNumber)
        
        ivSeat.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        lblSeatNumber.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-8)
        }
        
        didSelectSeatHandler = {
            self.didSelectSeat()
        }
    }
    
    func setData(for seat: BusSeat, isSelected: Bool) {
        self.seat = seat
        self.isSelectedSeat = isSelected
        
        lblSeatNumber.text = seat.seatNo
        
        if isSelectedSeat {
            ivSeat.image = UIImage(named: "bus_selected_seat")
            lblSeatNumber.textColor = .white
        } else {
            if seat.seatStatusType == "AVAILABLE" {
                ivSeat.image = UIImage(named: "bus_available_seat")
                lblSeatNumber.textColor = .textBlack
            } else if seat.seatStatusType == "DISABLE" {
                ivSeat.image = UIImage(named: "bus_lock_seat")
                lblSeatNumber.textColor = .white
                lblSeatNumber.text = ""
            } else if seat.seatStatusType == "UNAVAILABLE" || seat.seatStatusType == "PENDING" || seat.seatStatusType == "HOLD" || seat.seatStatusType == "CONFIRMED" {
                ivSeat.image = UIImage(named: "bus_unavailable_seat")
                lblSeatNumber.textColor = .white
            } else if seat.seatStatusType == "NONE" {
                ivSeat.image = nil
                lblSeatNumber.textColor = .white
            }
        }
    }
    
    private func didSelectSeat() {
        if self.seat?.seatStatusType == "AVAILABLE" {
            print(self.seat?.seatNo ?? "none selected seat")
            
            isSelectedSeat.toggle()
            
            if isSelectedSeat {
                ivSeat.image = UIImage(named: "bus_selected_seat")
                lblSeatNumber.textColor = .white
            } else {
                ivSeat.image = UIImage(named: "bus_available_seat")
                lblSeatNumber.textColor = .textBlack
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
    }
    
}
