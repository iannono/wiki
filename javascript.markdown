5-31
============

## ES2015

let 定义的变量有自己的作用域， 只能在block中进行访问
这样当我们在作用域外引用变量的时候， 是会出现错误提示的

一个常见的问题是：

```javascript
function callback(username) {
  console.log(username);
}

let userNames = ["ken", "clark", "ian"]

// 由于var i在代码执行前已经定义， 所以在函数执行的时候， 对应的i已经为3了
function loadProfiles(userNames) {
  for(var i in userNames) {
    setTimeout(function(){
      console.log(userNames[i])
    }, 1000);
  }
}
loadProfiles(["ian", "ken", "clark"])

// 但是如果这样则不行
function loadProfiles(userNames) {
  for(var i in userNames) {
    setTimeout(callback(userNames[i]), 1000);
  }
}
loadProfiles(["ian", "ken", "clark"])


// 如果改成let则可以避免这个问题
function loadProfiles(userNames) {
  for(let i in userNames) {
    setTimeout(function(){
      console.log(userNames[i])
    }, 1000);
  }
}

// 不同作用域中的let
let flashMessage = "Hello";
let flashMessage = "Hello"; // can't be redeclared
function loadProfiles(userNames){
  let flashMessage = "Loading profiles";
  return flashMessage;
}
```

const 常量定义

```javascript
const MAX_USERS = 3; // 必须有初始值
MAX_USERS = 10; // 无法重新定义

// const也是基于block的作用域

if(userNames.length > MAX_USERS){
  const MAX_REPLIES = 15;
}
console.log(MAX_REPLIES); // ReferenceError, MAX_REPLIES is not defined.
```

可变参数

```javascript
// Q: 使用可变参数前， 判断参数是否有效的方式
function loadProfiles(userNames){
  let names = typeof userNames !== 'undefined' ? userNames : [];
  let namesLength = names.length;
}

// R: 通过设置默认值可以解决这个问题
function loadProfiles(userNames = []){...


// Q: 当想传递多个参数的时候， 我们无法通过参数定义了解有哪些参数
function setPageThread(name, options = {}){
  let popular = options.popular;
  let expires = options.expires;
  let activeClass = options.activeClass;
  //...
}

// R: 命名参数可以解决这个问题
function setPageThread(name, { popular, expires, activeClass = "aa" }){
  console.log("Name: ", name);
  console.log("Popular: ", popular);
  console.log("Expires: ", expires);
  console.log("Active: " , activeClass); //未传递的值设置为undefined
}

setPageThread("New Version out Soon!", {
  popular: true,
  expires: 10000,
});

// 更进一步, 通过设置默认值，可以在调用的时候，省略该参数
function setPageThread(name, { popular, expires, activeClass } = {}){
  console.log(name);
  console.log(popular);
};
setPageThread("New Version out Soon!")
```

省略参数

```javascript
function displayTags(targetElement, ...tags){
  console.log(targetElement);
  console.log(tags);
  for(let i in tags){ // 这里tags是一个数组
    console.log(tags[i]);
  }
}

setTimeout(function(data){
  let tags = ["no1", "no2", "no3"];
  displayTags(...tags); //这里tags是多个参数
}, 1000)
```

函数与对象间的转换

```javascript
function TagComponent(target, urlPath){
  this.targetElement = target;
  this.urlPath       = urlPath;
}

function displayTags(target, ...tags) {
  console.log(target);
  console.log(tags);
}

TagComponent.prototype.render = function(){
  setTimeout(function(data){
    let tags = ["ken", "ian", "clark"];
    displayTags(this.targetElement, ...tags); //this.targetElement is undefined
  }, 1000);
}

let tagComponent = new TagComponent(document.getElementById("target_div"), "/topics/17/tags");
tagComponent.render();


// 通过火箭运算符来继承父作用域
getRequest(this.urlPath, (data) => {
  let tags = data.tags;
  displayTags(this.targetElement, ...tags);
});
```

对象初始化的省略

```javascript
// 当我们返回的对象名和变量名是一致的， 则可以省略变量名的定义
function buildUser(first, last){
  let fullName = first + " " + last;
  return { first, last, fullName, isActive(){return true} };
}

// 同样可以用在定义变量中
let name = "Sam";
let age = 45;
let friends = ["Brook","Tyler"];

let user = { name, age, friends }; //equal to let user = { name: name, age: age, friends: friends }

// 对象解构
let { first, last, fullName } = buildUser("Sam", "Williams")
let { last, fullName } = buildUser("Sam", "Williams")
let user = buildUser("Sam", "Williams")
console.log(first)
console.log(user)
```

字符串模板
```javascript
let veryLongText = `Hi ${userName},
  this is a very
  very
  veeeery
  long text.
  Regards,
  ${admin.fullName}
`;
```

Object.assign
```javascript
function countdownTimer(target, timeLeft, options = {}){
  let defaults = {
    a: "a",
    b: "b",
    c: "c"
  };
  // 该方法是模仿jquery的merge
  let settings = Object.assign({}, defaults, options);
  console.log(settings);
}
countdownTimer("target", "100", {a: "d"})
```

数组操作
```javascript
let users = ["Sam", "Tyler", "Brook"];
let [a, b, c] = users;
let [a, , c] = users;
let [ first, ...rest ] = users;

for(let name of names){
  console.log(name);
}

// find 方法
let users = [
  { login: "Sam",     admin: false },
  { login: "Brook",   admin: true  },
  { login: "Tyler",   admin: true  }
];
let admin = users.find( (user) => {
  return user.admin;
});
let admin = users.find(user => user.admin)
console.log(admin)
```

Map操作
```javascript
let user1 = { name: "Sam" };
let user2 = { name: "Tyler" };
let totalReplies = {};
// 当我们使用对象作为key的时候， 因为对象都会被转化为“[object, object]”
totalReplies[user1] = 5;
totalReplies[user2] = 42;
console.log( totalReplies[user1] ); // 所以这两个对象的key都是一样的
console.log( totalReplies[user2] );
console.log( Object.keys(totalReplies) );

// 通过map对象， 可以解决这个问题
let totalReplies = new Map();
totalReplies.set( user1, 5 );
totalReplies.set( user2, 42 );
console.log( totalReplies.get(user1) );
console.log( totalReplies.get(user2) );

// 通过map对象， 可以在运行的时候， 动态的创建
let recentPosts = new Map();
createPost(newPost, (data) => {
  recentPosts.set( data.author, data.message )
});

let recentPosts = new Map();
createPost(newPost, (data) => {
  recentPosts.set( data.author, data.message );
});

socket.on('new post', function(data){
  recentPosts.set( data.author, data.message );
});

// map 对象是可以进行遍历的
let mapSettings = new Map();
mapSettings.set( "user", "Sam" );
mapSettings.set( "topic", "ES2015" );
mapSettings.set( "replies", ["Can't wait!", "So Cool"] );
mapSettings.get("replies")
for(let [key, value] of mapSettings){
  console.log(`${key} = ${value}`);
}

// weakMap对象只接受对象作为key， 而且不能遍历
let mapSettings = new WeakMap();
mapSettings.set( user, "ES2015" );

// weakMap在内存使用上占用更少， 因为它支持垃圾收集
```

Set集合
```javascript
// set的key是唯一的, 并且也是可以遍历的
let tags = new Set();
tags.add({ version: "2015" });
tags.add("Web");
tags.add("Web");

// 同样存在weakSet, 但是不能遍历， 必须以对象作为key
// 同时weakSet不能通过get方法获取其中存取的值
// 那么我们要weakSet干嘛呢？
// 主要用于不改变对象状态的情况下， 对对象进行操作

// 假设我们需要判断post是否已读， 我们需要修改post的属性来判断
let post1 = { title: "hello1", content: "world1" };
let post2 = { title: "hello2", content: "world2" };
let post3 = { title: "hello3", content: "world3" };
let post4 = { title: "hello4", content: "world4" };

post1.isRead = true
let postArray = [post1, post2, post3, post4];

for(let post of postArray){
  if(!post.isRead){
    console.log(post);
  }
}

// 而通过weakSet， 可以直接判断是否包含已读post
let readPosts = new WeakSet();
readPosts.add(post1);
for(let post of postArray){
  if(!readPosts.has(post)){
    console.log(post)
  }
}
```

Class
```javascript
class Widget {
  constructor() {
    this.baseCss = "site-widget";
  }
  parse() {
  }
}

class SponsorWidget {
  constructor(name, description, url){
    super();
    this.name        = name;
    this.description = description;
    this.url = url;
  }
  render(){
    let parsedName = this.parse(this.name);
    let css = this._buildCSS(this.baseCSS);
  }
}

// 重写父类的方法
parse(){
  let parsedName = super.parse(this.name);
  return `Sponsor: ${parsedName}`;
}
```

Module
```javascript
// flash-messages.js
// 使用default只能导出一个方法
export default function(message){
  alert(message);
}
function logMessage(message){
  console.log(message);
}

// app.js
import flashMessage from './flash-message';
flashMessage("hello world!")

// 如果需要导出多个方法, 我们需要去掉default
export  function alertMessage(message){..
export  function logMessage(message){..
// 名字必须和模块中的一样
import { alertMessage, logMessage } from './flash-message';

// 将方法导出到一个对象中
import * as flash from './flash-message';
flash.alertMessage("haha");
flash.logMessage("haha");

// 简化export
export {alertMessage, logMessage}

// 如何在模块间共享常量
// constants.js
const MAX_USERS = 3
const MAX_REPLIES = 5
export {MAX_USERS, MAX_REPLIES}
import { MAX_REPLIES, MAX_USERS } from './constants';
//也可以选择只导出部分
import { MAX_REPLIES } from './constants'


// 导出class
// defalut允许在import的时候， 指定任意的值
export default class FlashMessage {
  constructor(message){
    this.message = message;
  }
  renderAlert(){
    alert(`${this.message} from alert`);
  }
  renderLog(){
    console.log(`${this.message} from log`);
  }
}
import FlashMessage from './flash-message';
import Message from './flash-message'; //名字可以不一样

let flash = new FlashMessage("Hello");
flash.renderAlert();
flash.renderLog();

// 也可以使用和function一样的导出方式, 但是这种情况下， 名字必须一样
export {FlashMessage}
import FlashMessage from './flash-message';
```

Promise
```javascript
 getPollResultsFromServer(pollName, function(error, results){ if(error){ //.. handle error }
  if(error){ //.. handle error }
  //...
  ui.renderSidebar(results, function(error){
    if(error){ //.. handle error }
    //...
    sendNotificationToServer(pollName, results, function(error, response){
      if(error){ //.. handle error }
      //...
      doSomethingElseNonBlocking(response, function(error){
        if(error){ //.. handle error }
        //... 
      });...

 getPollResultsFromServer("Sass vs. LESS")
  .then(ui.renderSidebar)
  .then(sendNotificationToServer)
  .then(doSomethingElseNonBlocking)
  .catch(function(error){
      console.log("Error: ", error);
  });

// 如何实现
function getPollResultsFromServer(pollName){
  return new Promise(function(resolve, reject){
    let q = function(request) {
      if (request.status >= 200 && request.status < 300)       {
        resolve(request.response);
      }else {
        reject(new Error(request.status));
      }
    };
    setTimeout(q, 1000, {status: 203, response: "hehehehe, success!"})
  });
};

//当我们调用promise对象的then方法的时候， 它会调用初始化时的方法，
//并将then方法的函数参数作为resolve传递进去
let fetchingResults = getPollResultsFromServer("Sass vs. Less");
fetchingResults
.then(function(results){
  console.log(`resolve called: ${results}`);
})
.catch(function(error){
  console.log(error);
})

```

如何实现一个迭代器
```javascript
let post = {
  title: "hello iterator",
  content: "how to write a iterator"
};

post[Symbol.iterator] = function(){
  let properties = Object.keys(this);
  let count = 0;
  let isDone = false;

  let next = () => {
    if(count >= properties.length){
      isDone = true;
    }
      return { done: isDone, value: this[properties[count++]] };
    }
  return { next };
};

for(let p of post) {
  console.log(p)
}
```

通过生成器生成迭代器
```javascript
// 每次调用yield都会生成一个新的迭代器对象
function *nameList(){
  yield "Sam"; // { done: false, value: "Sam"}
  yield "Tyler"; // { done: true, value: "Tyler"}
}

// 通过生成器来简化代码
post[Symbol.iterator] = function *(){
  let properties = Object.keys(this);
  for(let p of properties){
    yield this[p];
  }
};
```
