# vim: sts=2:ts=2:sw=2:et:tw=0

#type NetworkxException* = object of Exception
type NetworkxError* = object of Exception

proc raiseEx*(msg: string) {.discardable.} =
  raise newException(NetworkxError, msg)

template withcd*(newdir: string, statements: untyped) =
  let olddir = os.getCurrentDir()
  os.setCurrentDir(newdir)
  defer: os.setCurrentDir(olddir)
  statements
