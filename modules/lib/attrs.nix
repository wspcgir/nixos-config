{ lib, ... }: {
  common-lib = {
    map-attrs = func: list: lib.listToAttrs <| builtins.map func <| lib.attrsToList list;
    attr-values-flat = let 
      go = value: 
        if builtins.isAttrs value
        then builtins.concatMap (x: go x.value) (lib.attrsToList value)
        else if builtins.isList value 
        then value 
        else [value];
    in go;
  };
}
