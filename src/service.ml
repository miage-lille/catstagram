let ajax_get ~on_success ~on_error uri =
  let open Js_browser.XHR in
  let xhr = create () in
  let () = open_ xhr "GET" uri in
  let () =
    set_onreadystatechange xhr
    @@ fun () ->
    match ready_state xhr with
    | Done ->
        if status xhr >= 200 && status xhr < 300
        then response xhr |> on_success
        else response xhr |> on_error
    | _ -> ()
  in
  send xhr Ojs.null


module type GET = sig
  val make :
       on_ok:(string -> 'msg)
    -> on_error:(string -> 'msg)
    -> uri:string
    -> unit
    -> 'msg Vdom.Cmd.t

  val register : unit -> unit
end

module Get : GET = struct
  type 'msg Vdom.Cmd.t +=
    | Get of
        { on_ok : string -> 'msg
        ; on_error : string -> 'msg
        ; uri : string
        }

  let make ~on_ok ~on_error ~uri () = Get { on_ok; on_error; uri }

  let run ~on_ok ~on_error uri =
    ajax_get
      ~on_success:(fun t ->
        let open Js_browser.JsString in
        t_of_js t |> to_string |> on_ok)
      ~on_error:(fun t ->
        let open Js_browser.JsString in
        t_of_js t |> to_string |> on_error)
      uri


  [@@@warning "-8"]

  let cmd_handler ctx = function
    | Get { on_ok; on_error; uri } ->
        let _ =
          run
            ~on_ok:(fun s -> Vdom_blit.Cmd.send_msg ctx (on_ok s))
            ~on_error:(fun s -> Vdom_blit.Cmd.send_msg ctx (on_error s))
            uri
        in
        true


  [@@@warning "+8"]

  let register () = Vdom_blit.(register (cmd { Vdom_blit.Cmd.f = cmd_handler }))
end
