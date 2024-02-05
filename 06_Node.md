## 01 Node.js基础

### 特点

* 异步非阻塞的I/O（I/O线程池）input output
* 特别适用于I/O密集型应用
* 事件循环机制
* 单线程（成也单线程，败也单线程）
* 跨平台

### 应用场景

适合于I/O密集型，也就是经常请求数据库的，但是CPU压力很轻，一个服务员

## 02 Node基础

### Node中的函数

* Node中任何一个模块（js文件）都被一个**看不见的外层函数**所包裹；
* 这个函数用于支持模块化语法和隐藏服务器内部实现；

```javascript
function (exports, require, module, __filename, __dirname) { }
// exports：用于支持CommonJs模块化规范的暴露语法
// require：用于支持CommonJs模块化规范的引入语法
// module：用于支持CommonJs模块化规范的暴露语法
// __filename：当前运行文件的绝对路径
// __dirname：当前运行文件所在文件夹的绝对路径
```

### Node的global

* Node中this指向一个空对象，直接用global指向全局对象；
* global的一些常用属性
  * clearImmediate：清空立即执行函数
  * clearInterval：清除循环定时器
  * clearTimeout：清除延迟定时器
  * setImmediate：设置立即执行函数
  * setInterval：设置循环定时器
  * setTimeout：设置延迟定时器

### 缓冲器Buffer

*    它是一个【类似于数组】的对象，用于存储数据（存储的是二进制数据）；
*    Buffer的效率很高，存储和读取很快，它是直接对计算机的内存进行操作；
*    Buffer的大小一旦确定了，不可修改；
*    每个元素占用内存的大小为1字节；
*    Buffer是Node中的非常核心的模块，无需下载、无需引入，直接即可使用；

### 文件系统fs

* fs模块是Node的核心模块，使用的时候，无需下载，直接引入；

```javascript
// 简单文件写
let fs = require('fs') // fs.writeFile(file, data, [options], callback)
// 调用writeFile方法
fs.writeFile(__dirname + '/demo.txt', 'kobe,123', { mode: 0o666, flag: 'w' }, err => {
    if (err) console.log('文件写入失败', err)
    else console.log('文件写入成功')
})

// 简单文件读
fs.readFile(__dirname + '/test.mp4', function (err, data) {
    if (err) console.log(err)
    else console.log(data) // 读取出来的东西是Buffer，用户存储的不一定是纯文本
})
```

```javascript
// 流式文件写 fs.createWriteStream(path, [options])
let fs = require('fs')
// 创建一个可写流----水管到位了
let ws = fs.createWriteStream(__dirname + '/demo.txt', { start: 10 })
// 只要用到了流，就必须监测流的状态
ws.on('open', function () {
  console.log('可写流打开了')
})
ws.on('close', function () {
  console.log('可写流关闭了')
})
// 使用可写流写入数据
ws.write('美女\n')
ws.write('霉女？\n')
ws.write('到底是哪一个？\n')
ws.end() // 在Node的8版本中，要用end方法关闭流

// 流式文件读
// 创建一个可读流
let rs = fs.createReadStream(__dirname + '/music.mp3', {highWaterMark:10 * 1024 * 1024})
// 只要用到了流，就必须监测流的状态
rs.on('open',function () {
  console.log('可读流打开了')
})
rs.on('close',function () {
  console.log('可读流关闭了')
  ws.close() // 关闭流
})
```

## 03 Node 服务器

### 3.1 原生Node创建服务器

```javascript
const qs = require('querystring') // 将key=value&key=value...这种形式的字符串解析为对象

// 1.引入Node内置的http模块
const http = require('http')

// 2.创建服务对象
let server = http.createServer(function (request, response) {
  // 解析URL中的query参数
  // console.log(request.url) 结果是 /?name=zhangsan&age=18 这里的url不包括主机名
  let params = request.url.split('?')[1] // name=zhangsan&age=18
  let objParams = qs.parse(params) // { name: 'zhangsan', age: '18' }
  let { name, age } = objParams // 对象结构

  response.setHeader('content-type', 'text/html;charset=utf-8') // 设置响应头
  response.end(`<h1>你好${name},你的年龄是${age}</h1>`) // 设置响应内容
})

// 3.指定服务器运行的端口号(绑定端口监听)
server.listen(3000, function (err) {
  if (!err) console.log('服务器启动成功了')
  else console.log(err)
})
```

### 3.2 get和post请求

![2.GET与POST对比](Node.assets/GET与POST对比.png)

常见的默认GET请求：

* 浏览器地址栏输入网址时
* 可以请求外部资源的html标签，例如：`<img> <a> <link> <script>`
* form表单提交时，若没有指明方式，默认使用GET

### 3.3 Express创建服务器

express是基于Node.js的快速搭建服务器的框架

```javascript
// 1.引入express
const express = require('express')

// 2.创建app服务对象
const app = express()

// 3.配置后端路由：对请求的url进行分类，服务器根据分类决定交给谁去处理
app.get('/', function (request, response) {
  response.cookie('key', 'value') // 设置会话cookie
  // response.cookie('key', 'value', {maxAge:1000 * 30}) // 设置持久化cookie
  response.send('ok') // 响应内容
}

// 4.指定服务器运行的端口号(绑定端口监听)
app.listen(3000, function (err) {
  if (!err) console.log('服务器启动成功了')
  else console.log(err)
})
```

#### request和response的API

```javascript
// request
request.query	 // 获取查询字符串参数（query参数），拿到的是一个对象
request.params  // 获取get请求参数路由的参数，拿到的是一个对象
request.body	// 获取post请求体参数，拿到的是一个对象（不可以直接用，要借助一个中间件）
request.get(xxx)	// 获取请求头中指定key对应的value
// response
response.send()	// 给浏览器做出一个响应
response.end() // 给浏览器做出一个响应（不会自动追加响应头）
response.download()	// 告诉浏览器下载一个文件，可以传递相对路径
response.sendFile()	// 给浏览器发送一个文件，必须传递绝对路径（浏览器打不开的文件就会到下载）
response.redirect()	// 重定向到一个新的地址（url）
response.set(key, value)	// 自定义响应头内容
response.status(code)	// 设置响应状态码

// 案例
response.download('./public/vue.png')
response.sendFile(__dirname + '/public/demo.zip')
response.redirect('https://www.baidu.com')
response.status(200)
```

#### 参数路由

```javascript
app.get('/meishi/:id', function (request, response) {
  let { id } = request.params
  response.send(`我是编号为${id}的商家`)
})
```

#### 中间件

### 3.4 HTTP协议

HTTP协议是无状态的，cookie用于解决这个问题

* http 1.0：不支持长连接
* http 1.1：支持长连接，但是同时发送的资源数量过小
* http 2.0：同时发送的资源数量有所提升

#### 请求报文

```bash
### 请求报文首行:请求方式 协议名://主机地址:端口号/？urlencoded参数 HTTP协议名/版本
GET http://localhost:3000/?name=kobe&password=123 HTTP/1.1

### 请求头
Host: localhost:3000 # 发送请求的目标主机
Connection: keep-alive # 浏览器告诉服务器，浏览器支持长连接
Pragma: no-cache # 不走缓存
Cache-Control: no-cache # 不走缓存(强缓存)
Upgrade-Insecure-Requests: 1 # 浏览器告诉服务器可以使用 https或http1.1
DNT: 1 # 浏览器告诉服务器：禁止跟踪。最终是否跟踪，还得看服务器是否配合
User-Agent: Chrome/73.0.3683.75 Safari/537.36 ... # 用户代理，之前用于判断浏览器型号
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3 # 浏览器能够接收资源的类型及优先级，优先级q不写默认是1最高
Referer: http://localhost:63347/0719_node/demo.html?_ijt=tphpp47dag8jevtqrnq4 # 本次请求是“站”在哪里发出去的。可用于 1.防盗链。 2.广告计费
Accept-Encoding: gzip, deflate, br # 浏览器告诉服务器，浏览器所能接受的压缩文件类型
Accept-Language: zh-CN,zh;q=0.9,en-US;q=0.8,en;q=0.7 # 浏览器告诉服务器，浏览器所能支持的语言种类
Cookie: Webstorm-9af2238=09820128-3adb-43e4-8242-a6f65c9e523a # Webstorm给你种下的cookie

### 空行
### 请求体：GET请求没有请求体

### POST请求
Content-Length: 22 # 返回数据的长度
Origin: http://localhost:63347 # 精简版的Referer
Content-Type: application/x-www-form-urlencoded # 浏览器告诉服务器，携带参数的类型
### 请求体
name=kobe&password=123
```

* form表单的 post请求和get请求 参数均已`urlencoded`形式进行编码
* get请求将urlencoded编码的参数放入请求地址携带给服务器，所以称之为：**查询字符串参数**
* post请求将urlencoded编码的参数放入请求体，所以称之为：**请求体参数**

#### 响应报文

```bash
### 响应报文首行
HTTP/1.1 200 OK # 协议名/协议版本 状态码

### 响应头
X-Powered-By: Express # 服务器所采用的框架
Content-Type: text/html; charset=utf-8 # 告诉浏览器返回资源的类型及编码格式
Content-Length: 2 # 返回数据的长度
ETag: W/"2-eoX0dku9ba8cNUXvu/DyeabcC+s" # 协商缓存必要字段
Connection: keep-alive # 服务器告诉浏览器，下次请求时，或许会采用长连接

### 空行
### 响应体
OK
```

#### 状态码

* 1XX：服务器收到请求，需要请求者继续执行操作；
* 2XX：请求成功
  * 200：请求成功
* 3XX：重定向
  * 301：资源已永久转移到其他URL
  * 302：暂时重定向
  * 304：资源重定向到缓存，协商缓存
* 4XX：客户端错误，请求包含语法错误或无法完成请求
  * 400：请求信息错误；
  * 401：需要用户身份认证 Unauthorized；
  * 403：服务器拒绝客户端的请求 Forbidden；
  * 404：资源不存在 Not Found；
* 5XX：服务器错误
  * 500：服务器内部错误
  * 502 ：连接服务器失败

### 3.5 Cookie

#### Cookie

* 定义：本质就是一个【字符串】，里面包含着浏览器和服务器沟通的信息（交互时产生的信息）
* 存储的形式以：【key-value】的形式存储
* 浏览器会自动携带该网站的cookie，只要是该网站下的cookie，全部携带
* 分类：
  * 会话cookie（关闭浏览器后，会话cookie会自动消失，会话cookie存储在浏览器运行的那块【内存】上）
  * 持久化cookie：（看过期时间，一旦到了过期时间，自动销毁，存储在用户的硬盘上,备注：如果没有到过期时间，同时用户清理了浏览器的缓存，持久化cookie也会消失）
* 工作原理：
  * 当浏览器第一次请求服务器的时候，服务器可能返回一个或多个cookie给浏览器
  * 浏览器判断cookie种类：会话cookie：存储在浏览器运行的那块内存上；持久化cookie：存储在用户的硬盘上
  * 以后请求该网站的时候，自动携带上该网站的所有cookie（无法进行干预）
  * 服务器拿到之前自己“种”下cookie，分析里面的内容，校验cookie的合法性，根据cookie里保存的内容，进行具体的业务逻辑。
* 应用： 解决http无状态的问题（例子：7天免登录，一般来说不会单独使用cookie，一般配合后台的session存储使用）
* 不同的语言、不同的后端架构cookie的具体语法是不一样的，但是cookie原理和工作过程是不变的
* cookie不一定只由服务器生成，前端同样可以生成cookie，但是前端生成的cookie几乎没有意义
* 对比浏览器的本地存储：
  * localStorage：
    * 保存的数据，只要用户不清除，一直存在
    * 作为一个中转人，实现跨页签通信
    * 保存数据的大小：5MB-10MB
  * sessionStorage：
    * 保存的数据，关闭浏览器就消失
    * 保存数据的大小：5MB-10MB
  * cookie：
    * 会话cookie——关浏览器消失、持久化cookie——到过期时间消失
    * 保存数据的大小:4K-8K
    * 主要用于解决http无状态(一般配合后端的session会话存储使用)
    * 浏览器请求服务器时，会自动携带该网站的所有cookie

#### session

服务端session会话存储：客户端与服务器的通信数据保存在服务端的session中，服务端发送给客户端的cookie包含他们session的编号。session一般存储在服务端的内存当中；

session的持久化存储：借助数据库将session持久化存储

