# Koka-TAPL

用 [Koka](https://koka-lang.github.io/koka/doc/index.html) 学习并实现
*Types and Programming Languages*（TAPL，Benjamin C. Pierce）中的语言与类型系统。

本仓库的目标不是提供生产级实现，而是以 Koka 的代数效应（algebraic effects）
与处理器（handlers）为工具，尽可能贴近 TAPL 书中的定义与推导过程来编写代码，
并借此体会函数式语言在表达求值语义、类型规则与证明时的便利。

## 目录结构

```text
koka-tapl/
├── README.md
└── chapter-4/
    └── main.kk      -- TAPL 第 4 章：无类型算术表达式（NB / 布尔 + 自然数）
```

## chapter-4：无类型算术表达式

对应 TAPL 第 4 章 *An Untyped Arithmetic Language*，语言 `NB` 同时包含布尔值与
自然数（zero / succ / pred / isZero）以及条件表达式 `if ... then ... else ...`。

### 语法

`term` 数据类型对应书中的项（term）：

| 构造子                        | 含义                       |
| ----------------------------- | -------------------------- |
| `TmTrue` / `TmFalse`          | 布尔常量                   |
| `TmIf(t1, t2, t3)`            | 条件表达式                 |
| `TmZero`                      | 零                         |
| `TmSucc(t)`                   | 后继                       |
| `TmPred(t)`                   | 前驱                       |
| `TmIsZero(t)`                 | 判零                       |

### 求值

文件同时实现了书中给出的两种求值风格：

- **小步语义（small-step）**：`step` 实现单步归约，`eval-small` 反复调用 `step`
  直到得到值。归约规则与书中图 4-1 一一对应。
- **大步语义（big-step）**：`eval-big` 直接求值到 `value`，
  对应书中图 4-2 的求值关系 `t ⇓ v`。

`value` 数据类型只包含规范形式（canonical form）：

```text
VaTrue | VaFalse | VaZero | VaSucc(v)
```

### 错误处理

书中对“卡住的项”（stuck term，例如 `if 0 then ... else ...`）使用 `BadBoolean`
之类的标记，本实现改为使用 Koka 的效应来表达：

- `effect stuck`：自定义效应，通过 `final ctl stuck(message)` 直接中止计算并抛出
  一条人类可读的类型/求值错误信息。
- `exn`：对“已经求值到值却仍被 `step`”的情况，抛出 Koka 内建的异常。

`eval-small` 内部用 `handler` 捕获 `exn`，把“已到达值”映射为 `Nothing`
以便终止递归；其余错误信息（`stuck`）则保留在效应行中向外传播。

这样处理的好处是：函数的效应行 `<div, stuck>` / `<exn, stuck>`
显式描述了该计算可能产生的副作用，与 TAPL 中“求值可能卡住”这一语义
在类型上得到了对应。

## 构建与运行

需要安装 Koka 编译器（见 [官方文档](https://koka-lang.github.io/koka/doc/index.html)）。

```bash
# 编译并运行 chapter-4
koka chapter-4/main.kk
```

目前 `main.kk` 只定义了语言本身，尚无示例求值。若要试用，可自行在文件末尾
添加一个 `main` 函数，例如：

```kk
pub fun main()
  println(TmIsZero(TmPred(TmSucc(TmZero))).eval-small.show)
```

或对小步语义逐步归约过程进行打印观察。

## 进度

- [x] chapter-4：无类型算术表达式（NB）
  - [x] 语法定义
  - [x] 小步语义
  - [x] 大步语义
  - [x] stuck / 错误处理
- [ ] 后续章节（待补充）

## 参考

- Benjamin C. Pierce, *Types and Programming Languages*, MIT Press, 2002.
- [Koka 语言官方文档](https://koka-lang.github.io/koka/doc/index.html)
