# React学习笔记

## 组件

一个react组件是一个返回标签的JavaScript函数

组件只能接收一个参数，就是props对象

可以给props指定默认值

```jsx
function MyButton() {
  return (
    <button>I'm a button</button>
  );
}
```

不要在组件中嵌套组件，要在顶层定义组件，通过props传递数据

### 1 函数式组件

函数必须有返回值，是一个虚拟DOM

### 2 类式组件

```jsx
class MyComponent extends React.Component {
    state = {isHot:false}  // state属性存储状态数据，也可在构造器中初始化
    render() {
        const {isHot} = this.state
        return <h1 onClick={this.changeWeather}>今天天气很{isHot?'炎热':'凉爽'}</h1>
    }
    changeWeather = ()=>{
        const isHot = this.state.isHot
        this.setState({isHot:!isHot})  // 用setState方法修改状态数据
    }
}
ReactDOM.render(<MyComponent/>,document.querySelector('.test'))
```

### 组件三大属性

- state
- props
- refs

### 组件事件处理

在组件中声明事件处理函数来响应事件

```jsx
function MyButton() {
  function handleClick() {
    alert('You clicked me!');
  }

  return (
    <button onClick={handleClick}>
      Click me
    </button>
  );
}
```

注意`onClick={handleClick}`没有小括号，无需调用事件处理函数，React会帮助调用

### 函数柯里化

把接收多个参数的函数转化成多个只接收一个参数的函数

把函数的返回值设为一个新的函数，实现参数复用

```jsx
function add(a, b) {
    return a + b;
}
add(1, 2) // 3  普通做法 一次传入两个参数

// 假设有一个 curring 函数可以做到柯里化
function curring(){}
curring(1)(2) // 我们通过这样的方式来接受参数，这样就实现了柯里化
```

具体案例

```jsx
// before
function myInfo(inf, name, age) {
    return `${inf}：${name}${age}`
}
const myInfo1 = myInfo('个人信息', 'ljc', '19')
console.log(myInfo1); // 个人信息：ljc19

//  after curring
function myInfoCurry(inf) {
    return (name, age) => {
        return `${inf}：${name}${age}`
    }
}
let myInfoName = myInfoCurry('个人信息')
const myInfo1 = myInfoName('ljc', '19')
const myInfo2 = myInfoName('ljcc','19')
console.log(myInfo2); // 个人信息：ljcc119
console.log(myInfo1); // 个人信息：ljc19
```

## 组件生命周期

- 初始化
  - constructor：在组件初始化的时候只执行一次。用于初始化state和绑定函数
  - render：
- 更新
- 销毁

## 01 Redux 状态管理库

集中式状态管理JS库

![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/0ec99359-614b-44a5-91af-5625b610b864/Untitled.png)

**store：存储状态**

```jsx
store.dispatch(action对象)
```

**action：动作对象，包含两个属性 type data**

```jsx
export const createIncrementAction = data => ({
  type: INCREMENT,
  data
})
```

**reducer：初始化状态，加工状态**

```jsx
export default function countReducer(preState = initState, action) {
  const { type, data } = action;
  switch (type) {
    case INCREMENT:
      return preState + data
    case DECREMENT:
      return preState - data
    default:
      return preState
  }
}
```

通过createStore创建store时要传入reducers

store.getState的数据是reducers返回的

### useCallback

types.ts中写类型

saga.ts中写请求的函数

index.tsx中引入数据，使用useState，并通过props传递数据，在index中调用函数，使用useEffect

## 02 Hooks API 钩子

只能在组件的顶层调用 Hook

### 01 useState

给函数式组件添加状态：用于初始化以及更新组件状态

```jsx
const [count, setCount] = useState(0)

// setCount中可以直接传值，也可以传一个函数，该函数默认参数为oldValue，返回值为newValue
setCount((count) => { count + 1 });
```

### 02 useEffect

该 Hook 允许将组件与外部系统（网络、浏览器 API 或第三方库）同步，执行副作用操作（发送 ajax 请求，开启定时器等），或者叫做模拟生命周期

```jsx
useEffect(setup, dependencies?);

useEffect(() => {
	let timer = setInterval(() => {
		setCount(count => count + 1)
	}, 1000)
	return () => {
		clearInterval(timer);  // 组件将要被卸载时，执行该函数
	};
}, []);  // 监测count的变化
```

**参数 `setup`**

处理 Effect 的函数。`setup` 函数选择性返回一个清理 `cleanup` 函数。在将组件首次添加到 DOM 之前，React 将运行 `setup` 函数。在每次依赖项变更重新渲染后，React 将首先使用旧值运行 `cleanup` 函数（如果你提供了该函数），然后使用新值运行 `setup` 函数。在组件从 DOM 中移除后，React 将最后一次运行 `cleanup` 函数。

**参数 `dependencies`**

`setup` 代码中引用的所有响应式值的列表。如果省略此参数（全部监测），则在每次重新渲染组件之后，将重新运行 Effect 函数；如果此参数为空数组（全不监测），则 React 仅在组件初次挂载时执行一次 `setup` 函数，此后的重新渲染，都不会再次执行 `setup` 函数

- 接收两个参数，第一个参数为函数，在组件更新的时候执行；第二个参数为数组，表示需要追踪的变量列表，当变量更新时更新内容
- 第一个参数的返回值为一个函数，在useEffect执行之前，先执行返回的函数

**用法**

- 在开发环境下，React 在运行 `setup` 之前会额外运行一次 `setup` 和 `cleanup` ，用于压力测试，确认 `cleanup` 是否正确地映射到 `setup` 并可以停止或撤销 `setup` 正在执行的操作

### 03 useMemo

- 该钩子会从函数调用中创建/重新访问记忆化值，只有在第二个参数中传入的依赖项发生变化时，才会重新运行该函数
- 让组件中的函数跟随状态更新
- 优化函数组件中的功能函数

```jsx
const getDoubleNum = useMemo(() => {
	console.log('ddd');
	return 2 * num;
}, [num]);
```

- 接收两个参数，第一个参数为函数，第二个参数为数组的依赖列表。返回一个值

### 04 useCallback

（定义一个可变的函数？）

* 该 Hook 允许在多次渲染中缓存函数，它返回的也是一个函数。

```jsx
const cachedFn = useCallback(fn, dependencies);
```

**参数 `fn`**

- 表示想要缓存的函数，React会在初次渲染时返回该函数
- 下一次渲染时，如果依赖没有改变，React将返回相同的函数
- React不会调用该函数，由程序员自己调用

**参数 `dependencies`**

- 有关是否更新 `fn` 的所有响应式值的一个列表

**返回值**

- 在初次渲染时，`useCallback` 返回你已经传入的 `fn` 函数
- 在之后的渲染中, 如果依赖没有改变，`useCallback` 返回上一次渲染中缓存的 `fn` 函数；否则返回这一次渲染传入的 `fn`

**用法**

- 只用于性能优化，没有它也可正常运行
- 主要用于跳过组件的重新渲染：当父组件通过props给子组件传递一个函数时，如果没有使用useCallback缓存函数，则在每次父组件重新渲染时，会生成新的函数，导致子组件的重新渲染；而如果通过useCallback缓存该函数，在父组件重新渲染时，该函数不会重新生成，因此传递给子组件的props并没有发生变化，不会导致子组件的重新渲染（前提是子组件被memo包裹，在这种情况下，父组件重新渲染而props不变时，子组件会跳过重新渲染）

### 05 useReducer

* 类似于 useState，一般不用
* 接受一个 reducer 函数和一个初始 state 作为参数

```tsx
import { useReducer } from 'react';

// state 类型定义
interface State {
  count: number;
}

// 动作类型定义
type CounterAction = { type: 'reset' } | { type: 'setCount'; value: State['count'] };

// 初始化 state
const initialState: State = { count: 0 };

// reducer 函数定义
const stateReducer = (state: State, action: CounterAction): State => {
  switch (action.type) {
    case 'reset':
      return initialState;
    case 'setCount':
      return { ...state, count: action.value };
    default:
      throw new Error('Unknown action');
  }
};

export default function App() {
  const [state, dispatch] = useReducer(stateReducer, initialState);

  const addFive = () => dispatch({ type: 'setCount', value: state.count + 5 });
  const reset = () => dispatch({ type: 'reset' });

  return (
    <div>
      <h1>欢迎来到我的计数器</h1>

      <p>计数： {state.count}</p>
      <button onClick={addFive}>加 5</button>
      <button onClick={reset}>重置</button>
    </div>
  );

```



------

## 03 路由

react-router-dom库

```jsx
import { Link, BrowserRouter, Route } from 'react-router-dom'

<Link className="list-group-item" to="/about">About</Link>

<Route path="/about" component={About}></Route>
<Route path="/home" component={Home}></Route>

<Switch>
    <Route path="/home" component={Home}></Route>
    <Route path="/about" component={About}></Route>
    <Route path="/about" component={About}></Route>
</Switch>
```

**一般组件**：`<Demo/>`，**路由组件**：`<Route path="/demo" component={Demo}/>`

`React.memo` 的工作原理是，它会记住给定组件的最后一次渲染结果，如果下一次渲染时，这个组件的 props 没有改变，那么 React 就会直接使用上一次的渲染结果，而不会再次调用组件的渲染函数。这样可以避免不必要的渲染，提高应用的性能。

使用react-redux之后，容器组件可以自动检测redux中数据的改变并重新渲染页面。逻辑都在connect方法中

使用react-redux的Provider标签可以将store传给所有的容器组件



