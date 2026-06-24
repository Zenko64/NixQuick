{ stdenv, ... }:
stdenv.mkDerivation {
  pname = "bootTheme";
  version = "1.0";
  src = ./theme;

  installPhase = ''
    mkdir -p $out/share/plymouth/themes/bootTheme
    cp -r * $out/share/plymouth/themes/bootTheme
    find $out -name "*.plymouth" -exec sed -i "s|/usr|$out|g" {} +
  '';
}
