
# Meet TEA : Everything start with a counter

Our firts task is to create a simple counter using TEA.

## Representing application state with model 

First point is to define the initial state of our application. In TEA we store the state in the `model`. For a counter its type will be an `int` and inital value `0`

```ocaml
type model = int
let init = 0
```

## Handling events with messages and updates

Now we can represent the counter, we would like to provide buttons `-` and `+` to decrement or increment our model. If we were writing JavaScript, we might implement this logic by attaching an event listener to each button. ocaml-vdom wires up event handler a little bit differently. We need to write an `update` function that translate _messages_ into the desired `model`. The  message  should  describe _what happened_

```ocaml
type msg =
  | Increment
  | Decrement

let update model msg =
  match msg with
  | Increment -> model + 1
  | Decrement -> model - 1
```

## Writing view function 

### Expressive UI with functions

Browsers are translating HTML markup into a Document Object Model (a.k.a DOM) that represents the structure of the current page. The DOM consists of DOM nodes, and it’s only by changing these nodes that web applications can modify the current page.

The two most common types of DOM nodes are:
- _Elements_: These have a **tagName** (such as "button" or "div"), and may have child DOM nodes.
- _Text nodes_: These have a **textContent** property instead of a tagName, and are childless.

We want to display 2 buttons and a text:
```html
<div>
    <button> - </button>
    <span> 0 </span>
    <button> + </button>
</div>
```

This HTML produce the relative DOM:
![](./dom-counter.png)

When describing a document in ocaml-vdom we don't write markup. Instead we call functions to create the representation of DOM nodes.

```ocaml
let _ = div
        [ input ~a:[type_button; value "-"] []
        ; txt_span (string_of_int 0)
        ; input ~a:[type_button; value "+"] []
        ]
```

> The `div` function take as parameter a list of _child nodes_ ; `input` function take an optional named parameter `a`  which is a list of attributes and a second parameter which is a list of _child nodes_ (empty here) ; `txt_span` function take only a Text node as parameter.

ocaml-vdom provide funtions you can easily map to the equivalent DOM:
```ocaml
val div : ?key:string -> ?a:'a attribute list -> 'a vdom list -> 'a vdom
val input : ?key:string -> ?a:'a attribute list -> 'a vdom list -> 'a vdom
val txt_span : ?key:string -> ?a:'a attribute list -> string -> 'a vdom
```

You can see a pattern: functions are taking an optional parameter `key` (unique identifier of a node for ocaml-vdom), an optional parameter `a` (represents dom node attributes) and children (child nodes or text node)

In fact you can use `elt` function to generate any node:

```ocaml
(* Already defined in vdom module of ocaml-vdom *)
val elt : ns:string -> string -> ?key:string -> ?a:'a attribute list -> 'a vdom list -> 'a vdomlet 

let div ?key ?a l = elt "div" ?key ?a l
let input ?key ?a l = elt "input" ?key ?a l
let txt_span ?key ?a s = elt "span" ?key ?a [text s]
```

There is also a function to generate _Text nodes_
```ocaml
(* Already defined in vdom module of ocaml-vdom *)
val text : ?key:string -> string -> 'a vdom
```

So you can define any other HTML element you need in your app with ease:
```ocaml
(* exemple to define functions that generate new HTML element in app.ml *)
let ul =  ?key ?a l = elt "ul" ?key ?a l
let li =  ?key ?a l = elt "ul" ?key ?a l


(* you can also define element without children *)
let img ?key ?a () = elt "img" ?key ?a []
```


### The counter view

For this training we will use [TailwindCSS](https://tailwindcss.com/docs/container) to quickly add theming, so we can store string that will be provides as css class to our view functions:

```ocaml
let container_style = "flex justify-center p-4"

let button_style =
  "py-4 px-8 bg-indigo-500 text-white font-semibold rounded-lg shadow-md \
   hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-indigo-400 \
   focus:ring-opacity-75"


let counter_style = "py-4 px-8 mt-2 text-gray-500"
```

We can also add some utility functions to design our view:
```ocaml
let span txt = txt_span ~a:[ class_ counter_style ] txt

let button txt msg =
  input
    []
    ~a:[ onclick (fun _ -> msg); type_ "button"; value txt; class_ button_style ]
```

`span` function simply take a string and construct a node with the counter style. Since `class` is a reserved word in OCaml, `class_` stand for DOM `class` attribute (or VDOM `className`). Same goes for `type_`.

`button` construct an input button and attach our event handler to the `onclik` attributes.

Then we can write our view function that take the `model` as parameter:
```ocaml
let view model =
  div
    ~a:[ class_ container_style ]
    [ div
        [ button "-" Decrement
        ; string_of_int model |> span
        ; button "+" Increment
        ]
    ]
```

Notice that `view` builds fresh Html values after every update. That might sound like a lot of performance overhead, but in practice, it’s almost always a performance benefit!
This  is  because  ocaml-vdom  doesn’t  actually  re-create  the  entire  DOM  structure  of  the page every time. Instead, it compares the Html it got this time to the Html it got last time and  updates only the parts of the page that are different between the two requested representations. 

This approach to virtual  DOM  rendering,  popularized  by  the  JavaScript  library React, has several benefits over manually altering individual parts of the DOM:
- Updates are batched to avoid expensive repaints and layout reflows
- Application state is far less likely to get out of sync with the page
- Replaying application state changes effectively replays user interface changes

This explain the type of `view` function:

```ocaml
val view: model -> msg vdom
```

### Model-View-Update Loop

To create an ocaml-vdom application we need to wire all parts together.

```ocaml
let app = simple_app ~init ~view ~update ()
```

The `simple_app` function requires 3 named paramters:
- `init`: initial value of the `model`
- `view`: a function that take a `model` as parameter and return a Html node
- `update`: a functation that take a `model` and a `msg` and return a new `model`

The implementation of this architecture relies on two modules:

- `Vdom`: definition of the VDOM tree and of "virtual applications". This is a "pure" module, which does not depend on any Javascript bindings (it could be executed on the server-side, e.g. for automated testing).

- `Vdom_blit`: rendering of virtual applications into the actual DOM. This modules implements the initial "blit" operation (rendering a VDOM tree to the DOM) and the "diff/synchronization" algorithm. It also manages the state of a running application. Vdom_blit is implemented on top of Js_browser. `Js_browser` exposes (partial) OCaml bindings of the browser's DOM and other common client-side Javascript APIs.


We can finaly run the application and attach it to the Html document

```ocaml 
open Js_browser

let run () =
  Vdom_blit.run app
  |> Vdom_blit.dom
  |> Element.append_child (Document.body document)


let () = Window.set_onload window run
```

## Exercice 1: 

We only want the implement the rule: **Counter value must be greater than or equal to 3**.
- modify `update` function to avoid negative counter
- modify `view` function to disable the button `-` when counter value is 3

>💡 Tip: Why don't use this style <br/>
`let disabled_style =
  "py-4 px-8 bg-grey-700 text-white font-semibold rounded-lg shadow-md"`

  Now you are ready to [create your catstagram](./part2.md)