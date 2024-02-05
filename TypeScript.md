## 01 TypeScript 快速上手

### 1.1 基本使用

* 安装 TS `npm install -g typescript`，查看版本`tsc -V`
* 安装 ts-node `npm install -g ts-node` 可以在VS Code中直接运行ts文件
* 编写代码，文件扩展名为 `.ts`
* 编译代码，将文件编译成 `js` 文件`tsc helloword.ts`
* 运行 `js` 文件 `node helloworld.js`

### 1.2 VsCode 自动编译

* 使用 `tsc --init` 命令在当前文件夹下生成配置文件 `tsconfig.json`
* 修改配置文件两个地方 `"outDir": "./js"` `"strict": false`
* 启动监视任务：终端 -> 运行任务 -> 监视tsconfig.json

这样编写 ts 文件的时候会自动编译成 js 文件，并放在指定文件夹中

###  1.3 CodeRunner 运行

在 `setting.json` 中修改配置如下，可以指定编译后的文件的位置

```json
"code-runner.executorMap": {
    "typescript": "tsc --outFile ./js/$fileNameWithoutExt.js $fileName && node ./js/$fileNameWithoutExt.js"
},
```

## 02 特性

### 2.1 接口 interface

在 TypeScript 里，只要两个类型内部的结构兼容，那么这两个类型就是兼容的。 这就允许我们在实现接口时候只要保证包含了接口要求的结构就可以，而不必明确地使用 implements 语句

```typescript
interface Person { // 描述了一个对象
  firstName: string
  lastName: string
}

function greeter(person: Person) {
  return 'Hello, ' + person.firstName + ' ' + person.lastName
}

let user = {
  firstName: 'Yee',
  lastName: 'Huang'
}

console.log(greeter(user))
```

### 2.2 类

```typescript
class User {
  fullName: string
  firstName: string
  lastName: string

  constructor(firstName: string, lastName: string) {
    this.firstName = firstName
    this.lastName = lastName
    this.fullName = firstName + ' ' + lastName
  }
}
```

## 03 数据类型

### 3.1 基本类型

```typescript
let isDone: boolean = false
let a1: number = 10 // 十进制
let name: string = 'tom'
let u: undefined = undefined
let n: null = null
```

###  3.2 数组

```typescript
let list1: number[] = [1, 2, 3] // number 类型的数组
let list2: Array<number> = [1, 2, 3]
```

### 3.3 元组

元组类型允许表示一个已知元素数量和类型的数组，各元素的类型不必相同。 比如，你可以定义一对值分别为 string 和 number 类型的元组

```typescript
let t1: [string, number]
t1 = ['hello', 10] // OK 具有顺序性
```

### 3.4 enum 枚举类型

使用枚举类型可以为一组数值赋予友好的名字

```typescript
enum Color { Red, Green, Blue }

// 枚举数值默认从 0 开始依次递增 根据特定的名称得到对应的枚举数值
let myColor: Color = Color.Green // 0
console.log(myColor, Color.Red, Color.Blue) // 1 0 2

// 枚举类型提供的一个便利是你可以由枚举的值得到它的名字。 例如，我们知道数值为 2，但是不确定它映射到 Color 里的哪个名字，我们可以查找相应的名字
let colorName: string = Color[2]
console.log(colorName) // 'Green'
```

### 3.5 any 类型

```typescript
let notSure: any = 4
notSure = 'maybe a string'
notSure = false // 也可以是个 boolean
```

### 3.6 void 类型

```typescript
/* 表示没有任何类型, 一般用来说明函数的返回值不能是 undefined 和 null 之外的值 */
function fn(): void {
  console.log('fn()')
  // return undefined
  // return null
  // return 1 // error
}
```

### 3.7 object 类型

### 3.8 联合类型

表示取值可以为多种类型中的一种

```typescript
// 定义一个一个函数得到一个数字或字符串值的字符串形式值
function toString2(x: number | string): string {
  return x.toString()
}
```

### 3.9 类型断言

可以手动指定一个值的类型。

* 方式一: <类型>值；
* 方式二: 值 as 类型  tsx 中只能用这种方式

```typescript
// 需求: 定义一个函数得到一个字符串或者数值数据的长度
function getLength(x: number | string) {
  if ((<string>x).length) {
    return (x as string).length
  } else {
    return x.toString().length
  }
}
console.log(getLength('abcd'), getLength(1234)) // 4 4
```

## 04 接口

### 4.1 对象类型

**接口是对象的状态(属性)和行为(方法)的抽象(描述)**

TypeScript 的核心原则之一是对值所具有的结构进行类型检查。我们使用接口（Interface）来定义对象的类型。

```typescript
// 定义人的接口
interface IPerson {
  readonly id: number // readonly表示只读属性 一旦赋值就不可改变
  name: string
  age: number
  sex?: string // ?表示可选属性
}

// 定义一个对象
const person1: IPerson = {
  id: 1,
  name: 'tom',
  age: 20,
  sex？: '男'
}
// 类型检查器会查看对象内部的属性是否与 IPerson 接口描述一致, 如果不一致就会提示类型错误
```

### 4.2 函数类型

接口可以描述函数的参数类型和返回值类型

```typescript
// 定义函数接口：两个参数，类型为 string；返回值类型为 boolean
interface SearchFunc {
  (source: string, subString: string): boolean
}

// 定义一个函数
const mySearch: SearchFunc = function(source: string, sub: string): boolean {
  return source.search(sub) > -1
}
```

### 4.3 类类型

一个类可以实现多个接口

```typescript
interface Alarm {
  alert(): any
}

interface Light {
  lightOn(): void
  lightOff(): void
}

// 定义类
class Car2 implements Alarm, Light {
  alert() { console.log('Car alert') }
  lightOn() { console.log('Car light on') }
  lightOff() { console.log('Car light off') }
}
```

一个接口可以继承多个接口：和类一样，接口也可以相互继承。 这让我们能够从一个接口里复制成员到另一个接口里，可以更灵活地将接口分割到可重用的模块里。

```typescript
interface LightableAlarm extends Alarm, Light {}
```

## 05 类

### 5.1 类的定义

```typescript
// 定义类
class Greeter {
  message: string // 声明属性
  constructor(message: string) { // 构造方法
    this.message = message
  }
  greet(): string { // 一般方法
    return 'Hello ' + this.message
  }
}

// 创建类的实例
const greeter = new Greeter('world')
```

### 5.2 类的继承

用extends方法实现类的继承

```typescript
class Animal {
  run(distance: number) {
    console.log(`Animal run ${distance}m`)
  }
}

class Dog extends Animal {
  cry() {
    console.log('wang! wang!')
  }
}
```

### 5.3 修饰符

访问修饰符: 用来描述类内部的属性/方法的可访问性

* public：默认值，公开的外部也可以访问
* private：只能类内部可以访问
* protected：类内部和子类可以访问
* readonly修饰

## 06 函数

