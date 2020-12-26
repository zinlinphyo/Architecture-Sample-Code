//
//  BusSeatPlanViewController.swift
//  Flymya
//
//  Created by Zin Lin Phyo on 25/11/2019.
//  Copyright © 2019 Flymya.com. All rights reserved.
//

import UIKit
import AppsFlyerLib
import FirebaseAnalytics

class BusSeatPlanViewController: UIViewController {
    
    // MARK: - Attributes
    private var viewModel = BusSeatPlanViewModel()
    
    // MARK: - View Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: 1200)
        
        showLoadingIndicator()
        
        viewModel.selectedSeatList.removeAll()
        
        scrollView.scrollToTop()
        
        BusModel.shared().getSeatPlan(success: {
            self.viewModel.updateSeatList()
            
            self.busSeatCollectionView.reloadData()
            
            self.hideLoadingIndicator()
        }) { (error) in
            self.printError(error)
            self.hideLoadingIndicator()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        bindData()
    }
    
    // MARK: - Private Method
    
    private func bindData() {
        lblBusName.text = viewModel.busName
        lblBusRoute.text = viewModel.busRoute
        lblPassengerCount.text = viewModel.passengerCount
        lblSeatNumber.text = viewModel.seatNumbers
    }
    
    private func checkSeatCount() {
        if viewModel.isSelectedAllSeat() {
            btnContinue.backgroundColor = .primary
            btnContinue.isUserInteractionEnabled = true
        } else {
            btnContinue.backgroundColor = .textColorGray
            btnContinue.isUserInteractionEnabled = false
        }
    }
    
    // MARK: - Action Listener
    @objc private func didTapBtnBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func didTapBtnContinue() {
        showLoadingIndicator()
        BusModel.shared().reserveSeat(success: {
            self.hideLoadingIndicator()
            self.goToCustomer()
        }) { (error) in
            self.hideLoadingIndicator()
            self.printError(error)
            self.showAlertDialog(inputTitle: "Sorry!", inputMessage: error)
        }
    }
    
    private func didSelectSeat(to index: IndexPath) {
        viewModel.didSelectSeat(to: index, deselectAt: {_ in })
    }

    // MARK: - Navigation
    private func goToCustomer() {
        #if ENV_FLYMYA
        AppsFlyerModel.shared().trackEvent(eventName: AppConstants.analyticsEvent.bus.ot_select_seat, parameter: [:])
        Analytics.logEvent(AppConstants.analyticsEvent.bus.ot_select_seat, parameters: nil)
        #endif
        let vc = BusCustomerInfoViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - View Components
    /// Navigation Bar
    lazy var navigationBarView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.navigationBar
        return view
    }()
    
    lazy private var btnBack: UIButton = {
        let btn = UIButton()
        btn.setImage(#imageLiteral(resourceName: "Left Arrow 1158"), for: .normal)
        btn.addTarget(self, action: #selector(didTapBtnBack), for: .touchUpInside)
        return btn
    }()
    
    lazy var lblBusName: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .white
        lbl.font = UIFont(name: AppConstants.Font.Roboto.Bold, size: 16)
        return lbl
    }()

    lazy var lblBusRoute: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .white
        lbl.font = UIFont(name: AppConstants.Font.Roboto.Regular, size: 14)
        return lbl
    }()
    
    lazy var lblPassengerCount: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .white
        lbl.font = UIFont(name: AppConstants.Font.Roboto.Regular, size: 14)
        return lbl
    }()
    
    //------
    lazy var selectedSeatView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    lazy var lblSelectSeatTxt: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .black
        lbl.font = UIFont(name: AppConstants.Font.Roboto.Medium, size: 16)
        lbl.text = "Select your seat"
        return lbl
    }()
    
    lazy var lblSeatNumberTxt: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .black
        lbl.font = UIFont(name: AppConstants.Font.Roboto.Regular, size: 16)
        lbl.text = "Seat Number(s): "
        return lbl
    }()
    
    lazy var lblSeatNumber: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .primary
        lbl.font = UIFont(name: AppConstants.Font.Roboto.Bold, size: 18)
        lbl.numberOfLines = 2
        return lbl
    }()
    
    lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .primary
        return view
    }()
    
    //------
    lazy var scrollView: UIScrollView = {
        let view = UIScrollView(frame: .zero)
        view.backgroundColor = .bgGray
        view.autoresizingMask = .flexibleHeight
        view.bounces = true
        view.contentSize.height = 1256
        return view
    }()
    
    lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .bgGray
        return view
    }()
    
    lazy var lblPoweredby: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .textColorGray
        lbl.text = "Powered By"
        lbl.font = UIFont(name: AppConstants.Font.Roboto.Regular, size: 14)
        return lbl
    }()
    
    lazy var ivPoweredBy: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "mmbusticket-logo-hor")
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    lazy var busView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderColor = UIColor.gray.cgColor
        view.layer.cornerRadius = 5
        view.layer.borderWidth = 0.5
        view.clipsToBounds = true
        return view
    }()
    
    lazy var ivUnavailable: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "bus_unavailable_seat_circle")
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    lazy var lblUnavailable: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .black
        lbl.text = "Booked"
        lbl.font = UIFont(name: AppConstants.Font.Roboto.Regular, size: 14)
        return lbl
    }()
    
    lazy var ivAvailable: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "bus_available_seat_circle")
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    lazy var lblAvailable: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .black
        lbl.text = "Available"
        lbl.font = UIFont(name: AppConstants.Font.Roboto.Regular, size: 14)
        return lbl
    }()
    
    lazy var ivSelected: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "bus_selected_seat_circle")
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    lazy var lblSelected: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .black
        lbl.text = "Selected"
        lbl.font = UIFont(name: AppConstants.Font.Roboto.Regular, size: 14)
        return lbl
    }()
    
    lazy var ivDriverSeat: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "bus_driver_seat")
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    lazy var busSeperatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .borderGray
        return view
    }()
    
    lazy var busSeatCollectionView : UICollectionView = {
        let flowLayout = CenterAlignedCollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 0, height: 0)
        flowLayout.sectionInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumInteritemSpacing = 0.0
        
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.delegate = self
        cv.dataSource = self
        cv.register(BusSeatPlanCollectionViewCell.self, forCellWithReuseIdentifier: "BusSeatPlanCollectionViewCell")
        cv.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        cv.clipsToBounds = true
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.isScrollEnabled = false
        
        return cv
    }()
    
    lazy var btnContinue: UIButton = {
        let btn = UIButton()
        btn.setTitle("Continue", for: .normal)
        btn.titleLabel?.font = UIFont(name: AppConstants.Font.Roboto.Bold, size: 16)
        btn.backgroundColor = UIColor.textColorGray
        btn.titleLabel?.textColor = UIColor.white
        btn.isUserInteractionEnabled = false
        btn.layer.cornerRadius = 5
        btn.addTarget(self, action: #selector(didTapBtnContinue), for: .touchUpInside)
        return btn
    }()
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(navigationBarView)
        navigationBarView.addSubview(btnBack)
        navigationBarView.addSubview(lblBusName)
        navigationBarView.addSubview(lblBusRoute)
        navigationBarView.addSubview(lblPassengerCount)
        
        view.addSubview(selectedSeatView)
        selectedSeatView.addSubview(lblSelectSeatTxt)
        selectedSeatView.addSubview(lblSeatNumberTxt)
        selectedSeatView.addSubview(lblSeatNumber)
        selectedSeatView.addSubview(separatorView)
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
//        contentView.addSubview(lblPoweredby)
//        contentView.addSubview(ivPoweredBy)
        
        contentView.addSubview(busView)
        busView.addSubview(ivUnavailable)
        busView.addSubview(lblUnavailable)
        busView.addSubview(ivAvailable)
        busView.addSubview(lblAvailable)
        busView.addSubview(ivSelected)
        busView.addSubview(lblSelected)
        busView.addSubview(ivDriverSeat)
        busView.addSubview(busSeperatorView)
        busView.addSubview(busSeatCollectionView)
        
        contentView.addSubview(btnContinue)
        
        addConstraints()
    }
    
    func addConstraints() {
        //------
        navigationBarView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(statusBarHeight + 44)
        }
        
        btnBack.snp.makeConstraints { (make) in
            make.top.equalTo(view.snp.topMargin).offset(8)
            make.left.equalToSuperview().offset(8)
            make.width.height.equalTo(32)
        }
        
        lblBusName.snp.makeConstraints { (make) in
            make.top.equalTo(view.snp.topMargin)
            make.left.equalTo(btnBack.snp.right).offset(4)
        }
        
        lblBusRoute.snp.makeConstraints { (make) in
            make.top.equalTo(lblBusName.snp.bottom).offset(4)
            make.left.equalTo(lblBusName)
        }
        
        lblPassengerCount.snp.makeConstraints { (make) in
            make.top.equalTo(lblBusRoute)
            make.left.equalTo(lblBusRoute.snp.right)
        }
        
        //------
        selectedSeatView.snp.makeConstraints { (make) in
            make.top.equalTo(navigationBarView.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(56)
        }
        
        lblSelectSeatTxt.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.equalTo(0)
        }
        
        lblSeatNumberTxt.snp.makeConstraints { (make) in
            make.left.equalTo(lblSelectSeatTxt.snp.right).offset(0)
            make.centerY.equalToSuperview()
        }
        
        lblSeatNumber.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(lblSeatNumberTxt.snp.right).offset(8)
            make.right.equalTo(-16)
        }
        
        separatorView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(2)
        }
        
        //------
        scrollView.snp.makeConstraints { (make) in
            make.top.equalTo(selectedSeatView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(self.scrollView)
            make.left.right.equalTo(self.view)
            make.height.equalTo(1224)
        }
        
//        lblPoweredby.snp.makeConstraints { (make) in
//            make.top.equalToSuperview().offset(8)
//            make.left.equalToSuperview().offset(16)
//            make.width.equalTo(86)
//            make.height.equalTo(28)
//        }
//
//        ivPoweredBy.snp.makeConstraints { (make) in
//            make.left.equalTo(lblPoweredby.snp.right).offset(8)
//            make.centerY.equalTo(lblPoweredby)
//            make.height.equalTo(28)
//            make.width.equalTo(150)
//        }
        
        busView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(8)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        
        ivAvailable.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(8)
            make.centerY.equalTo(ivSelected)
            make.width.height.equalTo(48)
        }
        
        lblAvailable.snp.makeConstraints { (make) in
            make.left.equalTo(ivAvailable.snp.right)
            make.centerY.equalTo(ivSelected)
        }
        
        ivSelected.snp.makeConstraints { (make) in
            make.right.equalTo(lblSelected.snp.left)
            make.top.equalToSuperview().offset(8)
            make.width.height.equalTo(48)
        }
        
        lblSelected.snp.makeConstraints { (make) in
            make.left.equalTo(busView.snp.centerX)
            make.centerY.equalTo(ivSelected)
        }
        
        ivUnavailable.snp.makeConstraints { (make) in
            make.right.equalTo(lblUnavailable.snp.left)
            make.width.height.equalTo(48)
            make.centerY.equalTo(ivSelected)
        }
        
        lblUnavailable.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-8)
            make.centerY.equalTo(ivSelected)
        }
        
        ivDriverSeat.snp.makeConstraints { (make) in
            make.top.equalTo(ivUnavailable.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(16)
            make.width.height.equalTo(56)
        }
        
        busSeperatorView.snp.makeConstraints { (make) in
            make.top.equalTo(ivDriverSeat).offset(-4)
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
        }
        
        busSeatCollectionView.snp.makeConstraints { (make) in
            make.top.equalTo(ivDriverSeat.snp.bottom)
            make.left.equalToSuperview().offset(8)
            make.right.equalToSuperview().offset(-8)
            make.bottom.equalToSuperview()
//            make.height.equalTo(self.viewModel.rowCount * 50)
        }
        
        btnContinue.snp.makeConstraints { (make) in
            make.top.equalTo(busView.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(16)
            make.right.bottom.equalToSuperview().offset(-16)
            make.height.equalTo(48)
        }
        
        view.layoutIfNeeded()
    }
    
}

// MARK: -
extension BusSeatPlanViewController : UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.busSeatList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.busSeatList[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BusSeatPlanCollectionViewCell", for: indexPath) as? BusSeatPlanCollectionViewCell {
            cell.setData(for: viewModel.busSeatList[indexPath.section][indexPath.row], isSelected: viewModel.isSelectedSeat(for: indexPath))
            return cell
        }
        return UICollectionViewCell()
    }
    
}

extension BusSeatPlanViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let width = Int(collectionView.bounds.width) / viewModel.columnCount
        let width = Int(collectionView.bounds.width) / 5 //5 column fix - To make center alignment for seat plan view
        return CGSize(width: width, height: width)
    }
}

extension BusSeatPlanViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? BusSeatPlanCollectionViewCell
        
        if viewModel.busSeatList[indexPath.section][indexPath.row].seatStatusType == "AVAILABLE"  {
            cell?.didSelectSeatHandler()
            didSelectSeat(to: indexPath)
            self.lblSeatNumber.text = viewModel.seatNumbers
            collectionView.reloadData()
            checkSeatCount()
        }
    }
}

class busSeatPlanCollectionView : UICollectionView {
    
}

