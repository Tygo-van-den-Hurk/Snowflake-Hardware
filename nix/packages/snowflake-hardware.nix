{
  perSystem = { self', pkgs, ... }: {
    packages."snowflake-hardware" = pkgs.stdenv.mkDerivation rec {
      name = "snowflake-hardware";
      src = ../../src;

      nativeBuildInputs = [
        self'.packages.openjscad
        self'.packages.ergogen
        self'.packages.admesh
        pkgs.openscad
      ];

      unpackPhase = /* SHELL */ ''
        runHook preUnpack

        rm --force --recursive -- "$PWD"/*
        mkdir --parents -- "$PWD/src"
        cp --recursive --target-directory="$PWD/src" -- "$src"/*
        export src="$PWD/src"

        runHook postUnpack
      '';

      buildPhase = /* SHELL */ ''
        runHook preBuild

        # Generate all the outputs using `ergogen`.
        export ergogen_outputs="$PWD/ergogen-out"
        ergogen --clean --output "$ergogen_outputs" \
          --debug "$src"

        # Skipping all outlines that start with a `_`.
        export outline_outputs="$PWD/filtered-outlines"
        mkdir --parents -- "$outline_outputs"
        echo processing outlines:
        for outline in "$ergogen_outputs/outlines"/*; do
          name=$(basename "$outline" | sed 's/\..*//')
          echo "  - outline $name"
          [ ! -f "$outline" ] && continue
          [[ "$name" == _* ]] && continue
          mkdir --parents -- "$outline_outputs/$name"
          cp -- "$outline" "$outline_outputs/$name"
        done

        # Creating the mirror scad script to mirror STLs.
        export mirror_scad_script="$PWD/mirror.scad"
        echo 'mirror([1,0,0]) import(input);' > "$mirror_scad_script"
        echo "" >> "$mirror_scad_script"

        case_outputs="$PWD/cases"
        mkdir --parents "$case_outputs"
        echo processing cases:
        for case in "$ergogen_outputs/cases/"*; do
          name=$(basename "$case" | sed 's/\..*//')
          echo "  - case $name"

          [ ! -f "$case" ] && continue
          [[ "$name" == _* ]] && continue

          mkdir --parents -- $case_outputs/$name/left
          mkdir --parents -- $case_outputs/$name/right

          # Convert the case into a right and left and different formats
          openjscad "$case" -o "$case_outputs/$name/left/case.raw.stl"
          admesh $case_outputs/$name/left/case.raw.stl \
            --tolerance=1e-5 --iterations=3 --increment=5e-7 \
            --fill-holes --remove-unconnected --nearby \
            --normal-directions --exact --normal-values \
            --write-binary-stl=$case_outputs/$name/left/case.binary.stl \
            --write-ascii-stl=$case_outputs/$name/left/case.ascii.stl \
            --write-dxf=$case_outputs/$name/left/case.dxf \
            --write-off=$case_outputs/$name/left/case.off \
            --write-vrml=$case_outputs/$name/left/case.vrml

          echo "  trying to mirror: '$name' into a right version..."
          openscad -o "$case_outputs/$name/right/case.raw.stl" \
            -D "input=\"$case_outputs/$name/left/case.raw.stl\"" "$mirror_scad_script"

          echo ""
          echo "Checking $case_outputs/$name/right/case.raw.stl for mistakes and fixing them"
          admesh $case_outputs/$name/right/case.raw.stl \
            --tolerance=1e-5 --iterations=3 --increment=5e-7 \
            --fill-holes --remove-unconnected --nearby \
            --normal-directions --exact --normal-values \
            --write-binary-stl=$case_outputs/$name/right/case.binary.stl \
            --write-ascii-stl=$case_outputs/$name/right/case.ascii.stl \
            --write-dxf=$case_outputs/$name/right/case.dxf \
            --write-off=$case_outputs/$name/right/case.off \
            --write-vrml=$case_outputs/$name/right/case.vrml

          cp -- "$case" "$case_outputs/$name/blueprint.jscad"
        done

        echo ls
        ls "$case_outputs"

        runHook postBuild
      '';

      installPhase = /* SHELL */ ''
        runHook preInstall

        # Copying points
        mkdir --parents -- "$out/points"
        cp --recursive  -- \
          "$ergogen_outputs/points" "$out/points"

        # Copying source
        mkdir --parents -- "$out/source"
        cp --recursive  -- \
          "$ergogen_outputs/source" "$out/source"

        # Copying PCBs
        mkdir --parents -- "$out/pcbs"
        cp --recursive -- \
          "$ergogen_outputs/pcbs" "$out/pcbs"

        # Copying outlines
        mkdir --parents -- $out/outlines
        cp --recursive -- \
          "$outline_outputs"/* "$out/outlines"

        # Copying cases
        mkdir --parents -- "$out/cases"
        cp --recursive -- \
          "$case_outputs"/* "$out/cases"

        runHook postInstall
      '';
    };
  };
}
