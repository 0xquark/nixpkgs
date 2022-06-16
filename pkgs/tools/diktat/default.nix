{ lib, stdenv, fetchurl, makeWrapper, jre_headless }:

stdenv.mkDerivation rec {
  pname = "diktat";
  version = "1.1.0";

  src = fetchurl {
    url = "https://github.com/saveourtool/diktat/releases/download/v1.1.0/diktat-${version}.jar";
    sha256 = "sha256-d34IiPMlrDWSx4dU1q2cXGrlbyzKZl16x62sOORKhgg=";
  };

  nativeBuildInputs = [ makeWrapper ];

  dontUnpack = true;

  installPhase = ''
    install -Dm755 $src $out/bin/diktat
  '';

  postFixup = ''
    wrapProgram $out/bin/diktat --prefix PATH : "${jre_headless}/bin"
  '';

  meta = with lib; {
    description = " a strict coding standard for Kotlin and a collection of Kotlin code style rules implemented as AST visitors on the top of KTlin";
    homepage = "https://github.com/saveourtool/diktat";
    license = licenses.mit;
    platforms = jre_headless.meta.platforms;
    maintainers = with maintainers;[];
  };
}
