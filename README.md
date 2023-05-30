# SplitWeasley — Educational SplitWise Remake

SplitWeasly is a remake of the famous financial app, Splitwise.
It is a personal educational project, with the goal to practice coding and UX/UI skills and to populate portfolio.
Not intended for real-life usage, it is filled with stubbed data and has no backend connectivity.

## Redesign choices

- Mostly native components
- Extended functionality and improved UX:

  - Additional dynamic information on the amounts charged when editing a transaction's split parameters:
  
    ![Split Options](https://github.com/myra5hik/SplitWeasley/assets/80918676/ef16838a-4426-4677-be9a-89b0b84bbbdb)
  
  - Additional splits information in the transcation cells:
  
    ![Cells](https://github.com/myra5hik/SplitWeasley/assets/80918676/275c297a-81fc-47c5-9d01-dde135a844da)
    
- Light / Dark appearances supported

    ![Light Dark Mode](https://github.com/myra5hik/SplitWeasley/assets/80918676/e501e84a-bb0e-400f-b223-72742d483ff1)

## Implementation Details

### Strategy Pattern for Different Splitting Logics

Different strategy implementations enable a variety of ways to split monetary amounts, providing flexibility and extensibility of transaction splitting logics without coupling with UI layer.

To use the strategies, one can instantiate the desired strategy with a split group and a total monetary amount. Then, one calls the `amount(for personId:)` method to get the share for each member. The `set(_:for:)` method allows changing the strategy's parameter in a generic way.

```swift
protocol ISplitStrategy: ObservableObject {
    associatedtype SplitParameter

    // Logics
    var isLogicallyConsistent: Bool { get }
    // Descriptions
    var hintHeader: String { get }
    // ...
    func amount(for personId: Person.ID) -> MonetaryAmount?
    func set(_ value: SplitParameter, for personId: Person.ID)
}
```

The app's views can then depend on the reduced interface when details are not required:

```swift
final class AddTransactionScreenViewModel<...> {
    @Published var splitStrategy: any ISplitStrategy
    // ...
}
```

Or, when implementation details are required, such as in `SplitOptionsScreenView` (provides different split options to the user), views can utilise different implementations with the common interface to reduce their complexity and keep extensibility trivial:

```swift
struct SplitOptionsScreenView<...>: View {
    // Split parameters
    @StateObject private var equalSharesSplitStrategy: EqualSharesSplitStrategy
    @StateObject private var exactAmountSplitStrategy: ExactAmountSplitStrategy
    @StateObject private var percentageSplitStrategy: PercentageSplitStrategy
    // ...
    
    var hintPlateView: some View {
        ZStack {
            // ...
            let strategy = strategyForPickerSelection()
            Text(strategy.hintHeader).font(.headline)
            Text(strategy.hintDescription).font(.subheadline)
        }
        .frame(height: 60)
    }
}
```

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
