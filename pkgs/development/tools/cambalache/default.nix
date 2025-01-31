{ stdenv
, lib
, fetchFromGitLab
, python3
, meson
, ninja
, pkg-config
, gobject-introspection
, desktop-file-utils
, shared-mime-info
, wrapGAppsHook
, glib
, gtk3
, gtk4
, webkitgtk
, nix-update-script
}:

python3.pkgs.buildPythonApplication rec {
  pname = "cambalache";
  version = "0.10.1";

  format = "other";

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "jpu";
    repo = pname;
    rev = version;
    sha256 = "sha256-UgPyG1xDt624W+qTb88d0WvOza6YvVAO/YXeUV51Rro=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gobject-introspection # for setup hook
    desktop-file-utils # for update-desktop-database
    shared-mime-info # for update-mime-database
    wrapGAppsHook
  ];

  pythonPath = with python3.pkgs; [
    pygobject3
    lxml
  ];

  buildInputs = [
    glib
    gtk3
    gtk4
    webkitgtk
  ];

  # Not compatible with gobject-introspection setup hooks.
  # https://github.com/NixOS/nixpkgs/issues/56943
  strictDeps = false;

  # Prevent double wrapping.
  dontWrapGApps = true;

  postPatch = ''
    patchShebangs postinstall.py
  '';

  preFixup = ''
    # Let python wrapper use GNOME flags.
    makeWrapperArgs+=(
      # For broadway daemons
      --prefix PATH : "${lib.makeBinPath [ gtk3 gtk4 ]}"
      "''${gappsWrapperArgs[@]}"
    )
  '';

  postFixup = ''
    # Wrap a helper script in an unusual location.
    wrapPythonProgramsIn "$out/${python3.sitePackages}/cambalache/priv/merengue" "$out $pythonPath"
  '';

  passthru = {
    updateScript = nix-update-script {
      attrPath = pname;
    };
  };

  meta = with lib; {
    homepage = "https://gitlab.gnome.org/jpu/cambalache";
    description = "RAD tool for GTK 4 and 3 with data model first philosophy";
    maintainers = teams.gnome.members;
    license = with licenses; [
      lgpl21Only # Cambalache
      gpl2Only # tools
    ];
    platforms = platforms.unix;
  };
}
