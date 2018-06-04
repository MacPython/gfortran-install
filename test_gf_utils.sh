# Get gfortran utils
source gfortran_utils.sh

uname=$(uname)
FNAME_ROOT="openblas-v0.3.0"
export MACOSX_DEPLOYMENT_TARGET=10.6
ARCH_ROOT="archives/$FNAME_ROOT"
if [ $uname == Darwin ]; then
    # install_gfortran
    # [ -n "$GFORTRAN_DMG" ] || (echo "GFORTRAN_DMG not set"; exit 1)
    # [ -n "$GFORTRAN_SHA" ] || (echo "GFORTRAN_SHA not set"; exit 1)
    GFORTRAN_SHA=1becaaa76fe86f86df35f89ca30446c14a072d41
    target=$(echo $MACOSX_DEPLOYMENT_TARGET | tr .- _)
    PLAT_ROOT="macosx_$target"
    I686_PLAT="i386"
    SUF="gf_${GFORTRAN_SHA:0:7}"
elif [ $uname == Linux ]; then
    [ -z "$GFORTRAN_DMG" ] || (echo "GFORTRAN_DMG is set"; exit 1)
    [ -z "$GFORTRAN_SHA" ] || (echo "GFORTRAN_SHA is set"; exit 1)
    # Check check, if gfortran installed
    gfortran --help > /dev/null && check_gfortran
    PLAT_ROOT="manylinux1"
    I686_PLAT="i686"
    SUF=""
fi
if [ -n "$SUF" ]; then SUFP="-$SUF"; else SUFP=""; fi
exp_64_tgz="${ARCH_ROOT}-${PLAT_ROOT}_x86_64${SUFP}.tar.gz"
[ "$(get_gf_lib_for_suf "${SUF}" "${FNAME_ROOT}" "x86_64")" == "$exp_64_tgz" ] || \
    (echo Wrong tgz output; exit 1)
[ -f "$exp_64_tgz" ] || (echo Failed archive fetch; exit 1)
# Refetch does not raise error
[ "$(get_gf_lib_for_suf "${SUF}" "${FNAME_ROOT}" "x86_64")" == "$exp_64_tgz" ] || \
    (echo Wrong tgz output; exit 1)
# Check another archive
exp_32_tgz="${ARCH_ROOT}-${PLAT_ROOT}_${I686_PLAT}${SUFP}.tar.gz"
[ "$(get_gf_lib_for_suf "${SUF}" "${FNAME_ROOT}" "i686")" == "$exp_32_tgz" ] || \
    (echo Wrong tgz output; exit 1)
[ -f "$exp_32_tgz" ] || (echo Failed archive fetch; exit 1)
# Refetch does not raise error
[ "$(get_gf_lib_for_suf "${SUF}" "${FNAME_ROOT}" "i686")" == "$exp_32_tgz" ] || \
    (echo Wrong tgz output; exit 1)
# Check intel (fused)
if [ $uname == Darwin ]; then
    exp_fused_tgz="${ARCH_ROOT}-${PLAT_ROOT}_intel${SUFP}.tar.gz"
    [ "$(get_gf_lib_for_suf "${SUF}" "${FNAME_ROOT}" "intel")" == "$exp_fused_tgz" ] || \
        (echo Wrong tgz output; exit 1)
    [ -f "$exp_fused_tgz" ] || (echo Failed archive fetch; exit 1)
fi
# Same thing, setting the hash manually, for OSX
GFORTRAN_SHA="1becaaa76fe86f86df35f89ca30446c14a072d41"
rm $exp_64_tgz $exp_32_tgz
[ "$(get_gf_lib "${FNAME_ROOT}" "x86_64")" == "$exp_64_tgz" ] || \
    (echo Wrong tgz output; exit 1)
[ -f "$exp_64_tgz" ] || (echo Failed archive fetch; exit 1)
[ "$(get_gf_lib "${FNAME_ROOT}" "i686")" == "$exp_32_tgz" ] || \
    (echo Wrong tgz output; exit 1)
[ -f "$exp_32_tgz" ] || (echo Failed archive fetch; exit 1)
