{ lib
, stdenv
, fetchFromGitHub
, cmake
, ninja
, chromium
, grpc
, haskellPackages
, mercurial
, python3Packages
}:

stdenv.mkDerivation rec {
  pname = "re2";
  version = "2022-12-01";

  src = fetchFromGitHub {
    owner = "google";
    repo = "re2";
    rev = version;
    hash = "sha256-RmPXfavSKVnnl/RJ5aTjc/GbkPz+EXiFg1n5e4s6wjw=";
  };

  outputs = [ "out" "dev" ];

  nativeBuildInputs = [ cmake ninja ];

  postPatch = ''
    substituteInPlace re2Config.cmake.in \
      --replace "\''${PACKAGE_PREFIX_DIR}/" ""
  '';

  # Needed for case-insensitive filesystems (i.e. MacOS) because a file named
  # BUILD already exists.
  cmakeBuildDir = "build_dir";

  cmakeFlags = lib.optional (!stdenv.hostPlatform.isStatic) "-DBUILD_SHARED_LIBS:BOOL=ON";

  # This installs a pkg-config definition.
  postInstall = ''
    pushd "$src"
    make common-install prefix="$dev" SED_INPLACE="sed -i"
    popd
  '';

  doCheck = true;

  passthru.tests = {
    inherit
      chromium
      grpc
      mercurial;
    inherit (python3Packages)
      fb-re2
      google-re2;
    haskell-re2 = haskellPackages.re2;
  };

  meta = with lib; {
    description = "A regular expression library";
    longDescription = ''
      RE2 is a fast, safe, thread-friendly alternative to backtracking regular
      expression engines like those used in PCRE, Perl, and Python. It is a C++
      library.
    '';
    license = licenses.bsd3;
    homepage = "https://github.com/google/re2";
    maintainers = with maintainers; [ azahi ];
    platforms = platforms.all;
  };
}
