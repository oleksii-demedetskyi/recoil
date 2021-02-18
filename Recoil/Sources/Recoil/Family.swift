struct Family<Id: Hashable, T> {
    let key: (Id) -> Key
    let initial: (Id) -> T
}
