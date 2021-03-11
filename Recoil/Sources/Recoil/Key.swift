
public enum Key: Hashable {
    case atom(type: String)
    case family(type: String, id: AnyHashable)
    case derived(type: String)
}
