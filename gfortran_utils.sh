# Bash utilities for use with gfortran

GF_LIB_URL="https://3f23b170c54c2533c070-1c8a9b3114517dc5fe17b7c3f8c63a43.ssl.cf2.rackcdn.com"
ARCHIVE_SDIR="${ARCHIVE_SDIR:-archives}"

GF_UTIL_DIR=$(dirname "${BASH_SOURCE[0]}")

function get_distutils_platform {
    # Report platform as in form of distutils get_platform.
    # This is like the platform tag that pip will use.
    # Modify fat architecture tags on macOS to reflect compiled architecture

    # Deprecate this function once get_distutils_platform_ex is used in all
    # downstream projects
    local plat=$1
    case $plat in
        i686|x86_64|intel|aarch64|s390x|ppc64le) ;;
        *) echo Did not recognize plat $plat; return 1 ;;
    esac
    local uname=${2:-$(uname)}
    if [ "$uname" != "Darwin" ]; then
        if [ "$plat" == "intel" ]; then
            echo plat=intel not allowed for Manylinux
            return 1
        fi
        echo "manylinux1_$plat"
        return
    fi
    # macOS 32-bit arch is i386
    [ "$plat" == "i686" ] && plat="i386"
    local target=$(echo $MACOSX_DEPLOYMENT_TARGET | tr .- _)
    echo "macosx_${target}_${plat}"
}

function get_distutils_platform_ex {
    # Report platform as in form of distutils get_platform.
    # This is like the platform tag that pip will use.
    # Modify fat architecture tags on macOS to reflect compiled architecture
    # For non-darwin, report manylinux version
    local plat=$1
    local mb_ml_ver=${MB_ML_VER:-1}
    case $plat in
        i686|x86_64|intel|aarch64|s390x|ppc64le) ;;
        *) echo Did not recognize plat $plat; return 1 ;;
    esac
    local uname=${2:-$(uname)}
    if [ "$uname" != "Darwin" ]; then
        if [ "$plat" == "intel" ]; then
            echo plat=intel not allowed for Manylinux
            return 1
        fi
        echo "manylinux${mb_ml_ver}_${plat}"
        return
    fi
    # macOS 32-bit arch is i386
    [ "$plat" == "i686" ] && plat="i386"
    local target=$(echo $MACOSX_DEPLOYMENT_TARGET | tr .- _)
    echo "macosx_${target}_${plat}"
}

function get_macosx_target {
    # Report MACOSX_DEPLOYMENT_TARGET as given by distutils get_platform.
    python -c "import sysconfig as s; print(s.get_config_vars()['MACOSX_DEPLOYMENT_TARGET'])"
}

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
    local plat_tag=$(get_distutils_platform_ex $plat $uname)
    if [ -n "$suffix" ]; then suffix="-$suffix"; fi
    local fname="$prefix-${plat_tag}${suffix}.tar.gz"
    local out_fname="${ARCHIVE_SDIR}/$fname"
    if [ ! -e "$out_fname" ]; then
        curl -L "${GF_LIB_URL}/$fname" > $out_fname || (echo "Fetch failed"; exit 1)
    fi
    echo "$out_fname"
}

if [ "$(uname)" == "Darwin" ]; then
    mac_target=${MACOSX_DEPLOYMENT_TARGET:-$(get_macosx_target)}
    export MACOSX_DEPLOYMENT_TARGET=$mac_target
    GFORTRAN_DMG="${GF_UTIL_DIR}/archives/gfortran-4.9.0-Mavericks.dmg"
    GFORTRAN_SHA="$(shasum $GFORTRAN_DMG)"

    function install_gfortran {
        hdiutil attach -mountpoint /Volumes/gfortran $GFORTRAN_DMG
        sudo installer -pkg /Volumes/gfortran/gfortran.pkg -target /
        check_gfortran
        if [[ "${PLAT:-}" == "universal2" || "${PLAT:-}" == "arm64" ]]; then
            curl -L -O https://github.com/isuruf/isuruf.github.io/releases/download/v1.0/gfortran-darwin-arm64.tar.gz
            sudo mkdir -p /opt/
            sudo cp gfortran-darwin-arm64.tar.gz /opt/gfortran-darwin-arm64.tar.gz
            pushd /opt
                sudo tar -xvf gfortran-darwin-arm64.tar.gz
                sudo rm gfortran-darwin-arm64.tar.gz
            popd
            export FC_ARM64="/opt/gfortran-darwin-arm64/bin/arm64-apple-darwin20.0.0-gfortran"
            if [[ "${PLAT:-}" == "arm64" ]]; then
                export FC=$FC_ARM64
            fi
        fi
    }

    function get_gf_lib {
        # Get lib with gfortran suffix
        get_gf_lib_for_suf "gf_${GFORTRAN_SHA:0:7}" $@
    }
else
    function install_gfortran {
        # No-op - already installed on manylinux image
        check_gfortran
    }

    function get_gf_lib {
        # Get library with no suffix
        get_gf_lib_for_suf "" $@
    }
fi
