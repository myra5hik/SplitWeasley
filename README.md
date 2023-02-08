# SplitWeasley

SplitWeasly is a remake of the famous financial app, Splitwise.
It is a personal educational project, with the goal to practice coding and UX/UI skills and to populate portfolio.
Not intended for real-life usage, it is filled with stubbed data and has no backend connectivity.

## Redesign choices

- Mostly native components
- Light / Dark themes supported

    <img src="https://user-images.githubusercontent.com/80918676/215535712-94e7c616-2711-4f2a-aa8d-5097013cc782.png" width="25%" height="25%" /> <img src="https://user-images.githubusercontent.com/80918676/215537763-194d473f-cbe7-44de-b15b-9c2f63634432.png" width="25%" height="25%" />

- Extended functionality and improved UX:

  - Additional dynamic information on the amounts charged when editing a transaction's split parameters:
  
    <img src="https://user-images.githubusercontent.com/80918676/215532245-714c3dcc-b109-46f5-b6b7-8c74f6d2bb46.png" width="18%" height="18%" /> <img src="https://user-images.githubusercontent.com/80918676/215532380-f53312c4-b8be-4f18-80e7-6aa34f0c10ef.png" width="18%" height="18%" /> <img src="https://user-images.githubusercontent.com/80918676/215532411-53e48a94-18d9-42dd-a4b4-9a7db191d84e.png" width="18%" height="18%" /> <img src="https://user-images.githubusercontent.com/80918676/215532442-4895d328-a023-4277-837d-ed715eff59c7.png" width="18%" height="18%" /> <img src="https://user-images.githubusercontent.com/80918676/215532476-fb22c49d-19bd-4af1-b806-ccef2e507437.png" width="18%" height="18%" />
  
  - Additional splits information in the transcation cells:
  
    <img src="https://user-images.githubusercontent.com/80918676/215535712-94e7c616-2711-4f2a-aa8d-5097013cc782.png" width="25%" height="25%" />

## Implementation Details

### Routing 

Generic [Routing](https://github.com/myra5hik/SplitWeasley/tree/main/SplitWeasley/SplitWeasley/Routing) is implemented to decouple views.

- A [Router](https://github.com/myra5hik/SplitWeasley/blob/main/SplitWeasley/SplitWeasley/Routing/Router.swift) class, conforming to IRouter protocol, exposes navigation methods, taking generic RoutingDestination parameters as input:

```swift
protocol IRouter: ObservableObject {
    associatedtype RD: IRoutingDestination
    // ...
    func push(_ destination: RD)
    func pop()
    func present(_ destination: RD)
    func dismiss()
}
```

- The [Module](https://github.com/myra5hik/SplitWeasley/blob/main/SplitWeasley/SplitWeasley/Modules/GroupTransactionsModule.swift), holding onto the Router, defines the available RoutingDestination options:

```swift
enum RoutingDestination: IRoutingDestination {
    case transactionList
    case addTransactionScreen
    case transactionDetailView(id: SplitTransaction.ID)
    // ...
}
```

- The module creates a [PresentingView](https://github.com/myra5hik/SplitWeasley/blob/main/SplitWeasley/SplitWeasley/Routing/PresentingView.swift), injects the Router into it, and exposes the root view to be added into the view hierarchy:

```swift
final class GroupTransactionsModule: IGroupTransactionsModule {
    // Public
    var rootView: AnyView { presentingView.eraseToAnyView() }
    // Private
    private let router = Router<RoutingDestination>
    private let presentingView: PresentingView<R, GroupTransactionsModule>
}
```

- Views can then utilise the Router in the following manner:

```swift
router.present(.splitStrategySelector)
```
