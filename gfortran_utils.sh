# Bash utilities for use with gfortran

LIB_URL="https://3f23b170c54c2533c070-1c8a9b3114517dc5fe17b7c3f8c63a43.ssl.cf2.rackcdn.com"
ARCHIVE_SDIR="${ARCHIVE_SDIR:-archives}"

function check_gfortran {
    # Check that gfortran exists on the path
    if [ -z "$(which gfortran)" ]; then
        echo Missing gfortran
        exit 1
    fi
}

function get_gf_lib_for_suf {
    local suffix=$1
    local prefix=$2
    local plat=${3:-$PLAT}
    local uname=${4:-$(uname)}
    if [ -z "$prefix" ]; then echo Prefix not defined; exit 1; fi
    local fname="$prefix-${uname}-${plat}${suffix}.tar.gz"
    local out_fname="${ARCHIVE_SDIR}/$fname"
    if [ ! -e "$out_fname" ]; then
        curl -L "${LIB_URL}/$fname" > $out_fname || (echo "Fetch failed"; exit 1)
    fi
    echo "$out_fname"
}

if [ "$(uname)" == "Darwin" ]; then
    export MACOSX_DEPLOYMENT_TARGET="10.6"
    GFORTRAN_DMG="archives/gfortran-4.9.0-Mavericks.dmg"
    GFORTRAN_SHA="$(shasum $GFORTRAN_DMG)"

    function install_gfortran {
        hdiutil attach -mountpoint /Volumes/gfortran $GFORTRAN_DMG
        sudo installer -pkg /Volumes/gfortran/gfortran.pkg -target /
        check_gfortran
    }

    function get_gf_lib {
        # Get lib with gfortran suffix
        get_gf_lib_for_suf "-${GFORTRAN_SHA:0:7}" $@
    }
else
    function install_gfortran {
        # No-op - already installed on manylinux image
        check_gfortran
    }

    function get_gf_lib {
        # Get library with no suffix
        get_gf_lib_for_suff "" $@
    }
fi
