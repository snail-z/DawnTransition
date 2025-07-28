//
//  DemoListViewController.swift
//  DemoKit
//
//  Created by bible-team on 2025/7/22.
//  Copyright (c) 2025 bible-team All rights reserved.
//

import UIKit
import BibleBaseKit
import SnapKit

/// Demo 列表主页
public class DemoListViewController: BKBaseViewController {
    
    // MARK: - Properties
    
    private var allDemos: [DemoItem] = []
    private var filteredDemos: [DemoItem] = []
    private var groupedDemos: [DemoCategory: [DemoItem]] = [:]
    private var isSearching = false
    
    // MARK: - UI Components
    
    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchResultsUpdater = self
        controller.obscuresBackgroundDuringPresentation = false
        controller.searchBar.placeholder = "搜索 Demo"
        controller.searchBar.searchBarStyle = .minimal
        return controller
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.delegate = self
        table.dataSource = self
        table.backgroundColor = .systemGroupedBackground
        table.separatorStyle = .singleLine
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 80
        table.register(DemoListCell.self, forCellReuseIdentifier: "DemoListCell")
        table.register(DemoSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: "DemoSectionHeader")
        return table
    }()
    
    private lazy var emptyView: UIView = {
        let container = UIView()
        container.isHidden = true
        
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "doc.text.magnifyingglass")
        imageView.tintColor = .systemGray3
        imageView.contentMode = .scaleAspectFit
        
        let label = UILabel()
        label.text = "暂无 Demo"
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        
        container.addSubview(imageView)
        container.addSubview(label)
        
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-40)
            make.width.height.equalTo(80)
        }
        
        label.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(20)
        }
        
        return container
    }()
    
    // MARK: - Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadDemos()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        bk_navigationBar.setTitle("Demo 展示")
        
        // 添加视图
        view.addSubview(tableView)
        view.addSubview(emptyView)
        
        // 布局
        tableView.snp.makeConstraints { make in
            make.top.equalTo(bk_navigationBar.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        
        emptyView.snp.makeConstraints { make in
            make.top.equalTo(bk_navigationBar.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    private func loadDemos() {
        allDemos = DemoManager.shared.getAllDemos()
        filteredDemos = allDemos
        groupDemos()
        updateUI()
    }
    
    private func groupDemos() {
        groupedDemos.removeAll()
        
        for demo in filteredDemos {
            if groupedDemos[demo.category] == nil {
                groupedDemos[demo.category] = []
            }
            groupedDemos[demo.category]?.append(demo)
        }
    }
    
    private func updateUI() {
        let hasData = !filteredDemos.isEmpty
        tableView.isHidden = !hasData
        emptyView.isHidden = hasData
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource

extension DemoListViewController: UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return groupedDemos.keys.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let categories = Array(groupedDemos.keys).sorted { $0.rawValue < $1.rawValue }
        let category = categories[section]
        return groupedDemos[category]?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DemoListCell", for: indexPath) as! DemoListCell
        
        let categories = Array(groupedDemos.keys).sorted { $0.rawValue < $1.rawValue }
        let category = categories[indexPath.section]
        if let demos = groupedDemos[category] {
            let demo = demos[indexPath.row]
            cell.configure(with: demo)
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension DemoListViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let categories = Array(groupedDemos.keys).sorted { $0.rawValue < $1.rawValue }
        let category = categories[indexPath.section]
        if let demos = groupedDemos[category] {
            let demo = demos[indexPath.row]
            let viewController = demo.createViewController()
            viewController.title = demo.title
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "DemoSectionHeader") as! DemoSectionHeaderView
        
        let categories = Array(groupedDemos.keys).sorted { $0.rawValue < $1.rawValue }
        let category = categories[section]
        header.configure(with: category)
        
        return header
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
}

// MARK: - UISearchResultsUpdating

extension DemoListViewController: UISearchResultsUpdating {
    
    public func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        
        if searchText.isEmpty {
            isSearching = false
            filteredDemos = allDemos
        } else {
            isSearching = true
            filteredDemos = DemoManager.shared.searchDemos(keyword: searchText)
        }
        
        groupDemos()
        updateUI()
    }
}

// MARK: - Demo List Cell

public class DemoListCell: UITableViewCell {
    
    private lazy var iconView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue.withAlphaComponent(0.1)
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemBlue
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var tagsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 6
        stack.distribution = .fill
        return stack
    }()
    
    private lazy var arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = .tertiaryLabel
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(iconView)
        iconView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(tagsStackView)
        contentView.addSubview(arrowImageView)
        
        iconView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(44)
        }
        
        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(iconView.snp.right).offset(12)
            make.top.equalToSuperview().offset(12)
            make.right.equalTo(arrowImageView.snp.left).offset(-8)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.right.equalTo(titleLabel)
        }
        
        tagsStackView.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.top.equalTo(descriptionLabel.snp.bottom).offset(6)
            make.bottom.equalToSuperview().offset(-12)
            make.right.lessThanOrEqualTo(titleLabel)
        }
        
        arrowImageView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(16)
        }
    }
    
    public func configure(with demo: DemoItem) {
        iconImageView.image = UIImage(systemName: demo.category.icon)
        titleLabel.text = demo.title
        descriptionLabel.text = demo.description
        
        // 清空并重新添加标签
        tagsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for (index, tag) in demo.tags.prefix(3).enumerated() {
            let tagView = createTagView(with: tag)
            tagsStackView.addArrangedSubview(tagView)
            
            if index == 2 && demo.tags.count > 3 {
                let moreLabel = UILabel()
                moreLabel.text = "+\(demo.tags.count - 3)"
                moreLabel.font = .systemFont(ofSize: 12)
                moreLabel.textColor = .tertiaryLabel
                tagsStackView.addArrangedSubview(moreLabel)
            }
        }
    }
    
    private func createTagView(with text: String) -> UIView {
        let container = UIView()
        container.backgroundColor = .systemGray6
        container.layer.cornerRadius = 4
        
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        
        container.addSubview(label)
        label.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(6)
            make.top.bottom.equalToSuperview().inset(2)
        }
        
        return container
    }
}

// MARK: - Demo Section Header

public class DemoSectionHeaderView: UITableViewHeaderFooterView {
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemBlue
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        return label
    }()
    
    public override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.backgroundColor = .systemGroupedBackground
        
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        
        iconImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(iconImageView.snp.right).offset(8)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
        }
    }
    
    public func configure(with category: DemoCategory) {
        iconImageView.image = UIImage(systemName: category.icon)
        titleLabel.text = category.rawValue
    }
}
