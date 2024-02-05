##  01 Vue3 简介

* 使用 Proxy 代替 defineProperty 实现响应式；
* 重写虚拟 DOM 的实现和 Tree-Shaking；
* 更好的支持 TypeScript；

### 1.1 Vue3 新特性

1. Composition API（组合 API）

   - setup 配置
   - ref 与 reactive
   - watch 与 watchEffect
   - provide 与 inject
2. 新的内置组件
   - Fragment 
   - Teleport
   - Suspense
3. 其他改变

   - 新的生命周期钩子
   - data 选项应始终被声明为一个函数
   - 移除 keyCode 支持作为 v-on 的修饰符

### 1.2 使用 vue-cli 创建工程

```bash
## 安装或者升级脚手架
npm install -g @vue/cli
## 创建项目
vue create my-project
```

### 使用 Vite 创建工程

官方文档：https://v3.cn.vuejs.org/guide/installation.html#vite

* 开发环境中无需打包，快速冷启动；
* 轻量快速的热重载 HMR；
* 按需编译，不再等待整个应用编译完成

```bash
## 创建工程
npm init vite-app <project-name>
## 进入工程目录
cd <project-name>
## 安装依赖
npm install
## 运行
npm run dev
```

### 1.3 分析结构

```javascript
// main.js
import { createApp } from 'vue' // 引入的是一个名为 createApp 的工厂函数
import App from './App.vue' // 根组件
createApp(App).mount('#app') // 创建应用实例对象 app(轻量化的 vm)并挂载

// 类比 Vue2
import Vue from 'vue'  // 引入 Vue 构造函数
import App from './App.vue' // 根组件
new Vue({
  el: '#app'
  render: h => h(App),
})
```

## 02 常用组合式 API

### 2.1 理解 setup 配置项

* setup 配置项的值是一个函数；
* 组件中所用到的：数据、方法等等，均要配置在 setup 中，并通过 return 返回;
* setup 函数的两种返回值：
  * **若返回一个对象，则对象中的属性、方法，在模板中均可以直接使用**
  * 若返回一个渲染函数：则可以自定义渲染内容(不常用)
* Vue2 配置的(data、methos、computed...)可以访问 setup 中的数据；setup 中无法访问 Vue2 配置的数据
* setup 不能是一个 async 函数，因为返回值不再是 return 的对象，而是 Promise 实例对象，模板看不到 return 的 Promise 实例对象中的属性；
* 后期也可以返回 Promise 实例，需要与 Suspence 和异步组件搭配使用。

```javascript
export default {
  setup() {
    let name = 'Tom';  // 不具有响应式
    function sayHello() {
      alert(`My name is ${name}`)
    };
    return {
      name,  // 对象 key-value 的简写形式
      sayHello
    }
  }
}
```

### 2.2 ref 函数

* 作用：定义一个响应式的数据（一般是**基本类型**数据）；
* 创建一个包含响应式数据的**引用对象**（reference 对象，简称 ref 对象）；
* 将数据的值放在 `RefImpl` 实例对象的 value 属性上，通过 `Object.defineProperty()` 为其匹配 getter 和 setter，放在原型对象 `__proto__` 身上；
*  `RefImpl` 实例对象的原型对象 `__proto__` 类似于 `vm._data`，包含数据的 value 值和 getter 和 setter，之后通过数据代理，把 value 值代理到 **ref 对象**身上，便于使用；
* 在 JS 中：读取数据需要加 value；如果数据是对象，只需要在最外层加一次 value 即可，数据对象已经转为 Proxy 实例对象了；
* 在模板中：`{{ name }}` 不需要加 value
* ref 处理对象类型的数据，内部使用了 reactive 函数。

```javascript
import { ref } from 'vue'  // 引入 ref 函数

export default {
  setup() {
    let name = ref('zhangsan');  // name 变成了一个 RefImpl 的实例对象
    function changeInfo() {
      name.value = 'lisi';  // 通过 value 值读取和修改
      console.log(name.value)  // lisi
    };
    return { name, changeInfo }
  }
}
```

### 2.3 reactive 函数

* 功能：定义一个**对象类型**的响应式数据（基本类型不要用它，要用 ref 函数）；
* 内部基于 ES6 的 Proxy 实现，通过**代理对象**操作**源对象**内部数据进行操作；
* 将普通的 Object 实例对象变成了 Proxy 实例对象；
* 可直接通过索引修改数组的数据，也可以实现响应式；
* reactive 定义的响应式对象地址值不会发生变化；

```javascript
import { reactive } from 'vue'  // 引入函数

export default {
  setup() {
    let job = reactive({  // job 对象变成了一个 Proxy 的实例对象
      type: 'front-end',
      salary: '30k'
    });
    function changeInfo() {
      job.type = 'back-end';
      console.log(job.type);
    };
    return { job, changeInfo };
  };
}
```

### 2.4 ref 和 reactive

-  从定义数据角度对比：
   -  ref 用来定义：**基本类型数据**
   -  reactive 用来定义：**对象类型数据**（object, array, function）
   -  备注：ref 也可以用来定义对象类型数据, 它内部会自动通过 ```reactive``` 转为**代理对象**
-  从原理角度对比：
   -  ref 通过 ``Object.defineProperty()`` 的 get 与 set 来实现响应式（数据劫持）；
   -  reactive 通过使用 Proxy 来实现响应式（数据劫持）, 并通过 Reflect 操作源对象内部的数据；
-  从使用角度对比：
   -  ref 定义的数据：操作数据需要 ```.value```，读取数据时模板中直接读取不需要；
   -  reactive 定义的数据：操作数据与读取数据：均不需要 ```.value```

### 2.5 响应式原理

#### Vue2 响应式原理

* 对象类型：通过 `Object.defineProperty()` 对属性添加 getter 和 setter；
* 数组类型的通过 7 个变更数组的方法实现拦截；
* **存在的问题**
  * 对象新增属性、删除属性，界面不会更新
    * 添加属性使用 `this.$set() 或 Vue.set()` 解决；
    * 删除属性使用 `this.$delete() 或 Vue.delete()` 解决）；
  * 直接通过下标修改数组，界面不会更新；
    * 可通过 `this.$set() 或 Vue.set()` 解决；
    * 还可通过 7 种变更数组的方法解决。

#### Vue3 响应式原理

* `window.Proxy` 构造函数；
* 通过 Proxy（代理）:  拦截**源对象**中任意属性的变化，包括：属性值的读写、添加、删除等；
* 通过 Reflect（反射）:  对**源对象**的属性进行操作；`window.Reflect` 对象；
* `Reflect` 对象身上有 `get` `set` `deleteProperty` 方法，可用于操作对象属性；

```javascript
// person（target） 表示源对象；p 表示代理对象
const p = new Proxy(person, {
  // 有人读取 p 的某个属性时调用
  get(target, propName){
    console.log(`有人读取了 p 身上的${propName}属性`)
    return Reflect.get(target, propName)  // 从对象中读数据
    // return target[propName]  // propName 是个变量，要用方括号读取，不能用点
  },
  // 有人修改或新增 p 的某个属性时调用
  set(target, propName, value){
    console.log(`有人修改了 p 身上的${propName}属性，我要去更新界面了！`)
    Reflect.set(target, propName, value)
    // target[propName] = value
  },
  // 有人删除 p 的某个属性时调用
  deleteProperty(target, propName){
    console.log(`有人删除了p身上的${propName}属性，我要去更新界面了！`)
    return Reflect.deleteProperty(target, propName)
    // return delete target[propName]
  }
})
```

### 2.6 setup 注意事项

* setup 执行的时机：在 beforeCreate 之前执行一次，**setup 中的 this 是 undefined**；
* setup 接收的两个参数：
  * props：值为 **Proxy 对象**，包含：组件外部传递过来，**且组件内部声明接收了**的属性；
  * context：上下文对象（普通的 Object 对象）
    * attrs：值为对象，包含：组件外部传递过来，但没有在 props 配置中声明的属性，相当于 ```this.$attrs```
    * slots：收到的插槽内容，相当于 ```this.$slots```
    * emit：触发自定义事件的**函数**，相当于 ```this.$emit```

```javascript
export default {
  name: 'Demo',
  props: [ 'name', 'age' ],  // 声明接收 props 数据
  emits: [ 'hello' ],  // 声明接收自定义事件，如果不接收，默认为原生 DOM 事件
  setup(props, context) { 
  	function test() {
      context.emit("自定义事件", params)  // 触发自定义事件
    }
  }
}
```

### 2.7 计算属性 computed

```javascript
import { computed } from 'vue'  // 引入 computed 函数

setup() {
	// 计算属性——简写
  let fullName = computed(() => {
    return person.firstName + '-' + person.lastName
  });
  // 计算属性——完整写法
  person.fullName = computed({
    get() {
      return person.firstName + '-' + person.lastName
    },
    set(value) {
      const nameArr = value.split('-')
      person.firstName = nameArr[0]
      person.lastName = nameArr[1]
    }
  });
  return { fullname }
}
```

### 2.8 监视属性 watch

`watch(data, handler, options)` watch 函数可传入三个参数：数据、回调、配置

watch 监视的 data 不能是简单数据类型，只能是：

* ref 对象
* reactive 对象
* 一个函数，返回一个值
* 以上三种类型组成的数组

```javascript
import { ref, reactive, watch } from 'vue'  // 引入 watch 函数

/* ---------- 情况一：监视一个 ref 定义的基本类型数据 ---------- */
let sum = ref(0);

watch(sum, (newValue, oldValue) => {
	console.log('sum变化了', newValue, oldValue);
}, { immediate: true });

const stopWatch = watch(sum, (newValue, oldValue) => {
  console.log('sum变化了', newValue, oldValue);
  if (newValue >= 10) {
    stopWatch(); // 主动停止监视
  }
});

/* ---------- 情况二：监视一个 ref 定义的对象类型数据 ---------- */
// 监视的是这个对象的地址值，也就是直接给这个 变量.value 重复赋值时才会触发；可以通过加 .value，或者开启深度监视来实现对整个对象的监视
// 原理：因为这里 RefImpl 对象的 value 属性值是一个 Proxy 对象，所以要深度监视才能发现它改变了
let person = ref({ name: 'zhangsan', age: 18 });

// 写法1：相当于监视 reactive 定义的对象类型数据
watch(person.value, (newValue, oldValue) => {
  console.log('person的值变化了', newValue, oldValue);
});

// 写法2：深度监视
watch(person, (newValue, oldValue) => {
  console.log('person的值变化了', newValue, oldValue);
}, { deep: true });

/* ---------- 情况三：监视 reactive 定义的对象类型数据 ---------- */
let person = reactive({ name: 'zhangsan', age: 18 });

watch(person, (newValue, oldValue) => {
	console.log('person变化了', newValue, oldValue);
}); // 强制深度监视，无法关闭

/* ---------- 情况四：监视 reactive 定义的对象类型数据中的【某一个简单属性】 ---------- */
// 这里的监视的 data 要写成函数返回值的形式
watch(() => person.name, (newValue, oldValue) => {
	console.log('person 的 name 变化了', newValue, oldValue);
});

/* ---------- 情况五：监视 reactive 定义的对象类型数据中的【某一个对象属性】 ---------- */
// 这里的监视的 data 要写成函数返回值的形式，同时要开启深度监视
watch(() => person.job, (newValue, oldValue) => {
  console.log('person的job变化了', newValue, oldValue);
}, { deep: true });

/* ---------- 【监视数组】 ---------- */
// 1. 监视多个 ref 定义的响应式数据
watch([sum, msg], (newValue, oldValue) => {
	console.log('sum 或 msg 变化了', newValue, oldValue); // oldValue 和 newValue 也是数组
});

// 2. 监视 reactive 定义的响应式数据中的【某几个简单属性】
watch([() => person.name, () => person.age], (newValue, oldValue) => {
	console.log('person的几个变化了', newValue, oldValue);
});
```

### 2.9 watchEffect 函数

立即运行一个函数，同时响应式地追踪其依赖，并在依赖更改时重新执行该函数

* 不用指明监视哪个数据，监视的回调中用到哪个数据，那就监视哪个数据；
* 这里的数据类型和 watch 函数的数据类型一样？
* 默认一上来会执行一次，相当于 `immediate: true`；
* watchEffect 有点像 computed，所依赖的数据发生变化时，就执行回调：
  * 但 computed 注重的计算出来的值（回调函数的返回值），所以必须要写返回值；
  * 而 watchEffect 更注重的是过程（回调函数的函数体），所以不用写返回值；

```javascript
import { watchEffect } from 'vue'  // 引入 watchEffect 函数

// watchEffect 所指定的回调中用到的数据只要发生变化，则直接重新执行回调。
watchEffect(() => {
  const x1 = sum.value
  const x2 = person.age
  console.log('watchEffect 配置的回调执行了')
})
```

### 2.10 生命周期

可通过**配置项**的形式写生命周期，和 Vue2 类似，更改了两个名字，但不推荐使用。

- ```beforeDestroy``` 改名为 ```beforeUnmount```
- ```destroyed ``` 改名为 ``unmounted``

可通过组合式 API 的方式书写生命周期，写在 setup 中，要改名，还得通过 import 引入

`beforeCreate`      ===>  `setup()`

`created`           ===>  `setup()`

`beforeMount`       ===>  `onBeforeMount`

`mounted `           ===>  `onMounted`

`beforeUpdate `      ===>  `onBeforeUpdate`

`updated`           ===>  `onUpdated`

`beforeUnmount`     ===>  `onBeforeUnmount`

`unmounted`         ===>  `onUnmounted`

```javascript
export default {
  setup() {
    onBeforeMount(() => { console.log("挂载前") })
    return { }
  },
  mounted() { console.log("") }
}

```

### 2.11 自定义 hooks 函数

* 把 setup 函数中使用的 Composition API 进行了封装，类似 Vue2 中的 mixin；
* hooks 函数通常以 use 开头；
* 实现数据和方法的模块化

```javascript
/******************** hooks/useDog.js ********************/
import { reactive, onMounted } from "vue";
import axios from "axios";

export default function () {
  // 数据
  let dogList = reactive(["https://images.dog.ceo/breeds/pembroke/n02113023_4373.jpg"]);
  // 方法
  async function getDog() {
    try {
      let result = await axios.get("https://dog.ceo/api/breed/pembroke/images/random");
      dogList.push(result.data.message);
    } catch (error) {
      alert(error);
    }
  }
  // 钩子
  onMounted(() => {
    getDog();
  });
  
  // 向外部提供东西
  return { dogList, getDog };
}

/******************** Demo.vue 组件中 ************ ********/
import useDog from "./hooks/useDog"

const { dogList, getDog } = useDog();
```

### 2.12 toRef 函数

- 作用：创建一个 ref 对象，其 value 值指向另一个对象中的某个属性的值（**引用**）；
- 语法：```const newName = toRef(person, 'name')```
- 应用：**要将响应式对象中的某个属性单独提供给外部使用时**；
- 扩展：```toRefs``` 与 ```toRef``` 功能一致，但可以处理对象中第一层的所有属性，返回值是一个对象，该对象的每个 key 对应源对象的 所有属性。语法：```toRefs(person)``` 

```javascript
export default {
  setup() {
    let person = reactive({
      name:'张三',
      age:18,
    })
    // 把响应式对象 person 中的 name 属性引用出来到新的响应式数据
		const newName = toRef(person, 'name')  // newName 是 ref 对象
    // 把响应式对象 person 中的所有属性引用出来到新的响应式数据
		const p = toRefs(person)
    return { newName, ...p }  // 使用扩展运算符展开对象 p
  }
}
```

## 03 其他组合式 API

### 3.1 shallowReactive 与 shallowRef

- shallowReactive：只处理对象最外层属性的响应式（浅响应式）；
- shallowRef：只处理基本数据类型的响应式，不进行对象的响应式处理；（ref 处理对象类型的数据的时候会求助 reactive）；

- 什么时候使用：
  -  对象数据，结构比较深，但变化时只是外层属性变化 ===> `shallowReactive`
  -  对象数据，后续功能不会修改该对象中的属性，而是生成新的对象来替换 ===> `shallowRef`

### 3.2 readonly 与 shallowReadonly

-  `const person = readonly(person)`
- readonly：让一个响应式数据变为只读的（深只读）；
- shallowReadonly：让一个响应式数据变为只读的（浅只读）；深层数据可以修改
- 应用场景：不希望数据被修改时。

### 3.3 toRaw 与 markRaw

- `const p = toRaw(person)`
- toRaw：
  - 作用：将一个由 ```reactive``` 生成的响应式 **Proxy 对象**转为**普通对象**；
  - 使用场景：用于读取响应式对象对应的普通对象，对这个普通对象的所有操作，不会引起页面更新。
- markRaw：
  - 作用：标记一个对象，使其永远不会再成为响应式对象；
  - 应用场景：
    - 有些值不应被设置为响应式的，例如复杂的第三方类库等；
    - 当渲染具有不可变数据源的大列表时，**跳过响应式转换可以提高性能**。

```javascript
// 给 person 对象添加 car 信息（person 对象是响应式数据，由 reactive 生成的）
// 给 person 对象添加属性时，默认也是响应式的，因此需要用 markRaw 标记为普通对象
function addCar() {
	let car = { name: "car1", price: 40}
	person.car = markRaw(car)  // 将 car 对象标记为普通对象
}
```

### 3.4 customRef

- 作用：创建一个自定义的 ref，并对其依赖项跟踪和更新触发进行显式控制；

- ref 函数类似精装房，customRef 类似毛坯房；

- 实现防抖效果：


```vue
<template>
	<input type="text" v-model="keyword">
	<h3>{{ keyword }}</h3>
</template>

<script>
	import { ref, customRef } from 'vue'
	export default {
		name:'Demo',
		setup(){
			// let keyword = ref('hello')  // 使用 Vue 准备好的内置 ref
			// 自定义一个 myRef
			function myRef(value, delay){
				let timer  // 用于防抖的变量
				// 通过 customRef 去实现自定义
				return customRef((track, trigger) => {
					return {
						get() {  // 模板读数据时调用
							track() // 通知 Vue 追踪 value 值的变化
							return value
						},
						set(newValue) {  // 模板改数据时调用
							clearTimeout(timer)  // 防抖
							timer = setTimeout(() => {
								value = newValue  // 把修改后的值传给 value
								trigger()  // 通知 Vue 去更新界面
							}, delay)
						}
					}
				})
			}
			let keyword = myRef('hello', 500)  // 使用程序员自定义的 ref
			return {
				keyword
			}
		}
	}
</script>
```

### 3.5 provide 与 inject

依赖注入：祖先-->后代之间数据通信

```javascript
/******************** 祖先组件，提供数据 ********************/
import { provide } from "vue"  // 引入 provide 函数

setup(){
  let car = reactive({ name: '奔驰', price: '40万' })
  provide('car', car)  // 提供数据
}

/******************** 后代组件，接收数据 ********************/
import { inject } from "vue"  // 引入 inject 函数

setup() {
  const car = inject('car')  // 接收数据
  return { car }
}
```

### 3.6 响应式数据的判断

- 都是函数，都需要从 vue 引入
- isRef：检查一个值是否为一个 ref 对象
- isReactive：检查一个对象是否是由 `reactive` 创建的响应式代理
- isReadonly：检查一个对象是否是由 `readonly` 创建的只读代理
- isProxy：检查一个对象是否是由 `reactive` 或者 `readonly` 方法创建的代理

## 04 Composition API 的优势

### 4.1 Options API 存在的问题

使用传统 OptionsAPI 中，新增或者修改一个需求，就需要分别在 data，methods，computed 里修改

### 4.2 Composition API 的优势

借助 hook 函数，更加优雅的组织我们的代码，函数。让相关功能的代码更加有序的组织在一起

## 05 新的组件

### 5.1 Fragment

- 在 Vue2 中：组件必须有一个根标签；
- 在 Vue3 中：组件可以没有根标签，内部会将多个标签包含在一个 Fragment 虚拟元素中；
- 好处：减少标签层级，减小内存占用。

### 5.2 Teleport 组件

* 功能：能够将**组件 HTML 结构**移动到指定位置的技术（主要在样式相关的场景中使用）；
* 场景：弹窗，点子组件中的弹窗，传送到最外层组件，便于书写样式；
* `移动位置` 可以直接写 HTML 元素或 CSS 选择器（一般传给 `body` 标签）。

```vue
<teleport to="移动位置">
	<div v-if="isShow" class="mask">
		<div class="dialog">
			<h3>我是一个弹窗</h3>
			<button @click="isShow = false">关闭弹窗</button>
		</div>
	</div>
</teleport>
```

### 5.3 Suspense 组件

* 该组件内部使用插槽 slot 实现，内置两个具名插槽

```javascript
/******************** 静态引入 ********************/
import Child from './components/Child'

/******************** 异步引入 ********************/
import { defineAsyncComponent } from 'vue'
const Child = defineAsyncComponent(() => import('./components/Child'))
```

```html
<!-- 当 Child 组件是异步引入时，它就会晚些加载，为防止页面抖动，需配置反馈内容 -->
<Suspense>
  <template v-slot:default>
    <Child />
  </template>
  <template v-slot:fallback>
    <h3>稍等，加载中...</h3>
  </template>
</Suspense>
```

## 06 其他

### 6.1 全局API的转移

| 2.x 全局 API（```Vue```） | 3.x 实例 API (`app`)        |
| ------------------------- | --------------------------- |
| Vue.config.xxxx           | app.config.xxxx             |
| Vue.config.productionTip  | 移除                        |
| Vue.component             | app.component               |
| Vue.directive             | app.directive               |
| Vue.mixin                 | app.mixin                   |
| Vue.use                   | app.use                     |
| Vue.prototype             | app.config.globalProperties |

### 6.2 其他改变

* data 选项应始终被声明为一个函数；
* 移除 keyCode 作为 v-on 修饰符
* 移除 v-on 的 `.native` 修饰符
* 移除过滤器 `filter`

```vue
<my-component
  v-on:close="handleComponentEvent"
  v-on:click="handleNativeClickEvent"
/>

<script>
  export default {
    emits: ['close']  // 通过声明来区分自定义事件和原生 DOM 事件
  }
</script>
```

