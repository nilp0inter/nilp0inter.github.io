{
  outputs = { nixpkgs, ...}: {
    devShell.x86_64-linux = with nixpkgs.legacyPackages.x86_64-linux; mkShell {
      buildInputs = [ jekyll ];
      shellHook = "jekyll serve -l -o -H 0.0.0.0";
    };
  };
}
