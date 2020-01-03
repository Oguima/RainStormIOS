//
//  WeekViewController.swift
//  RainStorm
//
//  Created by Rafael Guimaraes Dos Santos on 19/11/19.
//  Copyright © 2019 Guima Games. All rights reserved.
//

import UIKit

final class WeekViewController: UIViewController {

    //MARK: View Model
    var viewModel: WeekViewModel? {
        didSet {
            guard let viewModel = viewModel else {
                return
            }
            setupViewModel(with: viewModel)
        }
    }
    
    @IBOutlet var tableView: UITableView! {
        didSet { //property observer...
            tableView.isHidden = true
            tableView.dataSource = self //precisa de UITableViewDataSource
            tableView.separatorInset = .zero
            tableView.estimatedRowHeight = 44.0
            tableView.rowHeight = 120.0 //UITableView.automaticDimension (Não deu)
            tableView.showsVerticalScrollIndicator = false
        }
    }
    
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView! {
        didSet {
            activityIndicatorView.startAnimating()
            activityIndicatorView.hidesWhenStopped = true
        }
    }
    
    //MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    //MARK: - Helper methods
    
    private func setupView()
    {
        view.backgroundColor = .white //.red
    }
    
    private func setupViewModel(with viewModel: WeekViewModel) {
        //print (viewModel)
        activityIndicatorView.stopAnimating()
        
        tableView.reloadData()
        tableView.isHidden = false
    }
}

extension WeekViewController: UITableViewDataSource {
    
    /*func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140.0;//Choose your custom row height
    }*/
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.numberOfDays ?? 0 //se não retorna um valor, deixa 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WeekDayTableViewCell.reuseIdentifier, for: indexPath) as? WeekDayTableViewCell else {
            fatalError("Unable to Dequeue Week Day Table View Cell")
        }
        
        guard let viewModel = viewModel else {
            fatalError("No view Model Present")
        }
        
        cell.configure(with: viewModel.viewModel(for: indexPath.row))
        return cell
    }
}
