import json, asyncnet, db_sqlite

type
  Client* = ref object
    socket*: AsyncSocket
    netAddr*: string
    id*: int
    connected*: bool

type
  Server* = ref object
    socket*: AsyncSocket
    clients*: seq[Client]

type
  Message* = object
    cmd*: string
    cip*: string
    session*: string

type
  Datastore* = ref object
    ds*: DbConn

type
  ClientEntity* = ref object
    id*: string
    netAddr*: string
    password*: string

type
  ClientResult* = ref tuple
    status: string
    client: ClientEntity

proc create_message*(cmd: string, cip: string = "-", session: string = "-"): string =
  result = $(%{
    "cmd": %cmd,
    "cip": %cip,
    "session": %session
  }) & "\c\1"

proc `$`*(msg: Message): string =
  $msg.cmd

proc parse_message*(data: string): Message =
  try:
    let dataJson = json.parseJson(data)
    result.cmd = dataJson["cmd"].getStr()
    result.cip = dataJson["cip"].getStr()
    result.session = dataJson["session"].getStr()
  except:
    result.cmd = "error"
