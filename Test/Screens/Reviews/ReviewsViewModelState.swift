/// Модель, хранящая состояние вью модели.
struct ReviewsViewModelState {

    var items = [any TableCellConfig & Identifiable]()
    var count = 0
    var limit = 20
    var offset = 0
    var shouldLoad = true

}

extension ReviewsViewModelState {

    mutating func reset() {
        items.removeAll()
        count = 0
        limit = 20
        offset = 0
        shouldLoad = true
    }
}
