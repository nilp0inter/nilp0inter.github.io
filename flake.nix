{
  description = "Build my personal site";

  outputs = { self, nixpkgs }: {

    packages.x86_64-linux.yst = nixpkgs.legacyPackages.x86_64-linux.haskellPackages.yst.out;

    packages.x86_64-linux.default = self.packages.x86_64-linux.yst;

  };
}
