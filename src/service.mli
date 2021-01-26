module type GET = sig
  val make :
       on_ok:(string -> 'msg)
    -> on_error:(string -> 'msg)
    -> uri:string
    -> unit
    -> 'msg Vdom.Cmd.t

  val register : unit -> unit
end

module Get : GET
