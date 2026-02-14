//
//  DriverTimelineDataSource.swift
//  Fleet
//
//  Created by forkon on 2019/10/23.
//  Copyright © 2019 waylens. All rights reserved.
//

protocol DriverTimelineDataSourceDelegate: class {
    func dataSource(_ dataSource: DriverTimelineDataSource, didReload cardModels: [TimelineCardModel], allIsLoaded: Bool)
    func dataSource(_ dataSource: DriverTimelineDataSource, didLoadMore cardModels: [TimelineCardModel], allIsLoaded: Bool)
}

class DriverTimelineDataSource {
    private var driver: Driver
    private lazy var currentDateRange: DateRange = initialDateRange
    private var numberOfDaysForLoadMore: Int = 3

    private var cardModels: [TimelineCardModel] = [] {
        didSet {
            filterData()
        }
    }

    weak var delegate: DriverTimelineDataSourceDelegate? = nil
    private(set) var initialDateRange: DateRange = DateRange(from: Date().adjust(.day, offset: -6), to: Date())

    private(set) var cardModelsFiltered: [TimelineCardModel] = []
    var dataFilter: DataFilter? = nil {
        didSet {
            filterData()
        }
    }

    required init(driver: Driver, initialDateRange: DateRange) {
        self.driver = driver
        self.initialDateRange = initialDateRange
    }

    func reload() {
        currentDateRange = initialDateRange

        WaylensClientS.shared.fetchDriverTimeline(
            driver.id,
            from: initialDateRange.from.millisecondsSince1970,
            to: initialDateRange.to.millisecondsSince1970
        ) { [weak self] (result) in
            guard let strongSelf = self else {
                return
            }

            var allIsLoaded = true

            switch result {
            case .success(let value):
                strongSelf.cardModels.removeAll()

                let eventGroup = strongSelf.parse(value)
                eventGroup.forEach { (key: Date, value: [DriverTimelineEvent]) in
                    let reversedValue = value.sorted{$0.time > $1.time}
                    strongSelf.cardModels.append(
                        TimelineCardModel(
                            date: key,
                            items: reversedValue.map{TimelineCardItem(timelineEvent: $0)}
                        )
                    )
                }

                allIsLoaded = strongSelf.cardModels.isEmpty ? true : false

                let to = strongSelf.currentDateRange.from.adjust(.day, offset: -(strongSelf.numberOfDaysForLoadMore - 1))
                strongSelf.currentDateRange = DateRange(from: to.adjust(.day, offset: -(strongSelf.numberOfDaysForLoadMore - 1)), to: to)
            case .failure(_):
                break
            }

            strongSelf.delegate?.dataSource(strongSelf, didReload: strongSelf.cardModels, allIsLoaded: allIsLoaded)
        }
    }

    func loadMore() {
        WaylensClientS.shared.fetchDriverTimeline(
            driver.id,
            from: currentDateRange.from.dateManager.fleetDate.dateAt(.startOfDay).date.millisecondsSince1970,
            to: currentDateRange.to.dateManager.fleetDate.dateAt(.endOfDay).date.millisecondsSince1970
        ) { [weak self] (result) in
            guard let strongSelf = self else {
                return
            }

            var allIsLoaded = true

            switch result {
            case .success(let value):
                let eventGroup = strongSelf.parse(value)
                eventGroup.forEach { (key: Date, value: [DriverTimelineEvent]) in
                    let reversedValue = value.sorted{$0.time > $1.time}
                    strongSelf.cardModels.append(
                        TimelineCardModel(
                            date: key,
                            items: reversedValue.map{TimelineCardItem(timelineEvent: $0)}
                        )
                    )
                }

                allIsLoaded = (eventGroup.isEmpty ? true : false)

                if !allIsLoaded {
                    let to = strongSelf.currentDateRange.from.adjust(.day, offset: -(strongSelf.numberOfDaysForLoadMore - 1))
                    strongSelf.currentDateRange = DateRange(from: to.adjust(.day, offset: -(strongSelf.numberOfDaysForLoadMore - 1)), to: to)
                }
            case .failure(_):
                break
            }

            strongSelf.delegate?.dataSource(strongSelf, didLoadMore: strongSelf.cardModels, allIsLoaded: allIsLoaded)
        }
    }

    func fetchEventDetail(_ eventID: String, completion: @escaping ((Event?, Error?) -> Void)) {
        WaylensClientS.shared.fetchEventDetail(driver.id, clipID: eventID) { [weak self] (result) in
            
            guard let strongSelf = self else {
                return
            }

            switch result {
            case .success(let value):
                if let data = value["data"] as? JSON {
                    if let eventData = try? JSONSerialization.data(withJSONObject: data, options: []),
                       let event = try? JSONDecoder().decode(Event.self, from: eventData){
                        completion(event, nil)
                    }
                }
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
}

//MARK: - Private

private extension DriverTimelineDataSource {

    func parse(_ responseJSON: [String : Any]) -> DriverTimelineEventGroup {
        if let eventDicts = responseJSON["timeline"] as? [[String : Any]] {
            let events = eventDicts.compactMap{try? JSONDecoder().decode(DriverTimelineEvent.self, from: $0.jsonData ?? Data())}
            return Dictionary(grouping: events, by:  {$0.time.dateManager.fleetDate.dateAt(.startOfDay).date}).sorted(by: {$0.key > $1.key})
        }
        return []
    }

    func filterData() {
        cardModelsFiltered = cardModels.filter({ (timelineCardModel) -> Bool in
            timelineCardModel.dataFilter = dataFilter
            return !timelineCardModel.itemsFiltered.isEmpty
        })
    }

}
