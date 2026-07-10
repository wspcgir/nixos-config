{ lib, ... }: {
  common-lib = {
    map-attrs = func: list: lib.listToAttrs <| builtins.map func <| lib.attrsToList list;
  };
}
