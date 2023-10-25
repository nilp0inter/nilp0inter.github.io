{
  outputs = { nixpkgs, ...}: {
    devShell.x86_64-linux = with nixpkgs.legacyPackages.x86_64-linux; mkShell {
      buildInputs = [ jekyll ];
      shellHook = "jekyll serve -lo";
    };
  };
}
