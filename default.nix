{ lib, callPackage, fetchFromGitHub, buildGoPackage, qt5Full }:

let
  pname = "goneovim";
  version = "0.5.1";
  owner = "akiyosi";
  repo = pname;
  rev = "v${version}";
in
buildGoPackage {
  inherit pname version rev;

  buildPhase = ''
    export GO111MODULE=off
    export QT_QMAKE_DIR=${qt5Full + "/bin"}
    export GOPATH=$PWD/go
    export GOROOT="$(go env GOROOT)"
    QTCMD=$PWD/go/src/github.com/therecipe/qt/cmd

    function build_tool()
    {
      echo building $1
      go build -o $GOPATH/bin/$1 $QTCMD/$1
    }
    build_tool qtmoc
    build_tool qtrcc
    build_tool qtdeploy

    echo running qtrcc
    cd /build/go/src/github.com/akiyosi/goqtframelesswindow
    $GOPATH/bin/qtrcc

    echo running qtmoc
    cd /build/go/src/github.com/akiyosi/goneovim
    $GOPATH/bin/qtmoc

    echo running qtdeploy
    cd /build/go/src/github.com/akiyosi/goneovim/cmd/goneovim
    $GOPATH/bin/qtdeploy build desktop
  '';

  goPackagePath = "github.com/${owner}/${repo}";

  src = fetchFromGitHub {
    inherit owner repo rev;
    sha256 = "sha256-dbdPvbIPpMaPl8RkM/s9X8pG8KGbzz53xnor+LNCOwY=";
  };

  goDeps = ./deps.nix;

  meta = with lib; {
    license = licenses.mit;
    homepage = "https://github.com/${owner}/${repo}";
    description = "Neovim GUI written in Golang, using a Golang qt backend";
    maintainer = with maintainers; [ ners ];
  };
}
