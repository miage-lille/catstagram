

# Catstagram

We will build a thumnbail of cats pictures.

## Iteration 1 : Fake data

We would like to display a thumbnail of pictures.

### US1 : Display the thumbnail

AS a user
I WANT to display a thumbnail of X pictures

BUSINESS RULE: X = min(value of the counter, number of avalaible pictures)

## Exercice 2: Implement US1 with fake datas

You can use this type with some fake datas:
```ocaml
module Picture = struct
  type t =
    { preview_url : string
    ; webformat_url : string
    ; user : string
    ; user_image_url : string
    }

  let fake_datas =
    [ { preview_url =
          "https://cdn.pixabay.com/photo/2017/02/20/18/03/cat-2083492_150.jpg"
      ; webformat_url =
          "https://pixabay.com/get/54e0dd404e5bae14f1dc846096293e761039d6e6574c704f742f7fd0914dc75f_640.jpg"
      ; user = "susannp4"
      ; user_image_url =
          "https://cdn.pixabay.com/user/2015/12/16/17-56-55-832_250x250.jpg"
      }
    ; { preview_url =
          "https://cdn.pixabay.com/photo/2015/04/23/21/59/tree-736877_150.jpg"
      ; webformat_url =
          "https://pixabay.com/get/51e3d34b4d55b10ff3d8992cc6213f7b1337dde14e507748752b7fd2974fc2_640.jpg"
      ; user = "Bessi"
      ; user_image_url =
          "https://cdn.pixabay.com/user/2019/04/11/22-45-05-994_250x250.jpg"
      }
    ; { preview_url =
          "https://cdn.pixabay.com/photo/2016/03/28/12/35/cat-1285634_150.png"
      ; webformat_url =
          "https://pixabay.com/get/57e2dd464c51a814f1dc846096293e761039d6e6574c704f742f7fd0914dc75f_640.png"
      ; user = "cocoparisienne"
      ; user_image_url =
          "https://cdn.pixabay.com/user/2020/11/18/08-17-40-870_250x250.jpg"
      }
    ]

end
```

Your tasks:
- Update the model type to store counter value and a list of pictures
- Update the update function to update the list of pictures while updating the counter value
- Update the view function to display the pictures


### US2 : Manage the popover

AS a user
WHEN I click on a picture
I WANT to display a modal with large picture, info about author and a close button

BUSINESS RULE: Clic on close button must close the modal

## Exercice 3: Implement US2 with fake datas

Your tasks:
- Update the model type to store the fact you may or not have selected a picture
- Create a new message that represent the fact you selected a picture
- Create a new message that represent the fact you closed the modal
- Update the update function
- Update the view function

## Iteration 2 :  Our application is no more a simple app

### Cats API

Start by creating an account on pixabay.com to get an API key https://pixabay.com/api/docs/

Then you can get your pictures from the API : 
`https://pixabay.com/api/?key=[your_api_key]&per_page=[counter_value]&q=cat`


### Manage effects

Since we will manage asynchronous effects (API call, random number, ...), our application must be modify.

Previously we only handled mouse interactions but what about talking to a server ?

Within TEA effects are managed by **commands** handled by the `vdom_blit` runtime, simple app was an app that doesn't trigger commands.

Signature of `simple_app`:
```ocaml
val simple_app:
  init:'model ->
  update:('model -> 'msg -> 'model) ->
  view:('model -> 'msg vdom) ->
  unit ->
  ('model, 'msg) app
```

To manage our API call, we need to replace it by an `app`:
```ocaml
val app:
  init:('model * 'msg Cmd.t) ->
  update:('model -> 'msg -> 'model * 'msg Cmd.t) ->
  view:('model -> 'msg vdom) ->
  unit ->
  ('model, 'msg) app
```

You noticed that `init` value and returned type of `update` function are now a tuple of `'model * 'msg Cmd.t`, the type `'msg Cmd.t` representing the **command**

We must modify our inital value in app.ml:
```ocaml
let init = return { counter = 3; pictures = [] }
```

The type of `Vdom.return` is `val return: ?c:'msg Cmd.t list -> 'model -> 'model * 'msg Cmd.t` so it take an optional list of **commands** and a **model** and return a tuple `'model * 'msg Cmd.t`. Since we don't want to dispatch message at the initialization

> 📌 `return` is not the statement you know in Java, Javascript, ... it is just a function. In functional programming a `return` function is just a function `val return : 'a -> 'a t`. It takes a "pure" value and jams it into your type. It is sometime named `pure` in some libs.

## Exercice 4: Create a app

Modify the `update` function to fit the new function signature and then run a `app` instead of a `simple_app`. At this step we still do not have effect but we are ready for.


## Iteration 3 :  Make a service call

I provide you a module to manage GET Api calls. All you have to do to use it in the `app.ml` is:

```ocaml
let () = Service.Get.register ()
```

> ⚠️ You may have an error from the langage server `ocamllsp` if you are using vscode: `Unbound module Service`. It's a bug in the plugin but it is ok, don't worry about it. 

Later you can create api calls using the make function of the Service.Get module:
```ocaml
 val make :
       on_ok:(string -> 'msg)
    -> on_error:(string -> 'msg)
    -> uri:string
    -> unit
    -> 'msg Vdom.Cmd.t
```

where `on_ok` is the callback when the api responded with a success code, `on_error` is the callback when the api responded with an error code, and `uri` is the uri of the api - here: `https://pixabay.com/api/?key=[your_api_key]&per_page=[counter_value]&q=cat`


`make` function gives us clues about the complexity of effects like calling an api:
- Asynchrounous: meaning we want to **wait** for a result, **without blocking** the whole application
- Success: the effect may or may not be successful and we have to manage both cases

We will need to represent this in our model and in our messages.

## Exercice 5: Send command for api calls

_At this step we will put all the plumbing but not yet parse the response_

Yours tasks:
    
- Update the model type
>💡 Tip: At the previous step the model would have been *an int counter AND a picture list* ; at this step the *picture list* should be modify for a type that defines something like a *loading OR success of a picture list OR failure of a string*

- Update the initial value
>💡 Tip: a success of an empty list seems a good idea

- Update the msg type
>💡 Tip: you will need additional values that represent the 3 new events: *call the service OR service call succeeded or service call failed*

- Create bindings to your callback functions 

>💡 Tip: at this step, you may log your response and return the appropriate message value. `on_ok` callback should return the message value that represents *service call succeeded* and `on_error` callback should return the message value that represents *service call failed*

## Iteration 4 :  Parse response to data

One of the hardest part when you start using statically typed langage for web programming is about parsing data.

We will use the [jsonoo](https://mnxn.github.io/jsonoo/jsonoo/index.html) lib that provides us all the decoder we need and works well with js_of_ocaml.

> ⚠️ I provide the libs info for later reading. You don't have to use it directly. I assume you already have knowledge of parsing problems. Cause it may be hard and boring I provide you a naive parser, sufficient for the training.

First we should take a look at a [sample of the body response from pixabay](../sample-api-response.json).

Our objective is to gets a `picture lits` from the `hits`. We can proceed with 2 steps:
a. Parse the string to a dictionnary whose keys are the fields of our picture record
b. Create a picture from the dictionnary

Assuming you have those 2 modules  - _you may adapt the parsing regarding your previous implementation if different_
```ocaml
module Picture = struct
  type t =
    { preview_url : string
    ; webformat_url : string
    ; user : string
    ; user_image_url : string
    }
end

module Pictures = struct
  type t =
    | Loading
    | Success of Picture.t list
    | Failure of string
end
```

Good to us, jsonoo dict decoder is a Stdlib.Hatbl. We can add a `from_dict` function in the `Picture` module:
```ocaml
module Picture = struct
  ...

  let from_dict dict =
    let preview_url = Hashtbl.find dict "previewURL"
    and webformat_url = Hashtbl.find dict "webformatURL"
    and user = Hashtbl.find dict "user"
    and user_image_url = Hashtbl.find dict "userImageURL" in
    { preview_url; webformat_url; user; user_image_url }
end
```

finally we can use jsonoo to parse the response string to `Pictures.t`:
```ocaml
module Pictures = struct
  ...
   let from_response resp =
    match Jsonoo.try_parse_opt resp with
    | None -> Failure "Invalid JSON Response"
    | Some json ->
        let open Jsonoo.Decode in
        let pic_list =
          json
          |> field
               "hits"
               (list
                  (dict (any [ string; map (fun i -> string_of_int i) int ])))
          |> List.map Picture.from_dict
        in
        Success pic_list
end
```

## Exercice 6: Finalize the app

At this step you should be able to plug all parts together to parse the response and make your app works with real datas.

## Bonus: Improve the app

Your tasks:
- At previous step, the parsing works while the api is consistent. Since REST/JSON is untyped it is totally unsafe. As an exemple, if any field is renamed you will get a javascript runtime error.
- Use tailwindCSS to make your app beautiful