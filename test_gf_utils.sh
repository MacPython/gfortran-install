# Get gfortran utils
source gfortran_utils.sh

uname=$(uname)
if [ $uname == Darwin ]; then
    install_gfortran
    [ -n "$GFORTRAN_DMG" ] || (echo "GFORTRAN_DMG not set"; exit 1)
    [ -n "$GFORTRAN_SHA" ] || (echo "GFORTRAN_SHA not set"; exit 1)
    SUF="-1becaaa"
elif [ $uname == Linux ]; then
    [ -z "$GFORTRAN_DMG" ] || (echo "GFORTRAN_DMG is set"; exit 1)
    [ -z "$GFORTRAN_SHA" ] || (echo "GFORTRAN_SHA is set"; exit 1)
    # Check check, if gfortran installed
    gfortran --help > /dev/null && check_gfortrangfortran --help > /dev/null && check_gfortran
    SUF=""
fi
exp_64_tgz="archives/openblas-0.2.18-${uname}-x86_64${SUF}.tar.gz"
[ "$(get_gf_lib_for_suf "${SUF}" "openblas-0.2.18" "x86_64")" == "$exp_64_tgz" ] || \
    (echo Wrong tgz output; exit 1)
[ -f "$exp_64_tgz" ] || (echo Failed archive fetch; exit 1)
# Refetch does not raise error
[ "$(get_gf_lib_for_suf "${SUF}" "openblas-0.2.18" "x86_64")" == "$exp_64_tgz" ] || \
    (echo Wrong tgz output; exit 1)
# Check another archive
exp_32_tgz="archives/openblas-0.2.18-${uname}-i686${SUF}.tar.gz"
[ "$(get_gf_lib_for_suf "${SUF}" "openblas-0.2.18" "i686")" == "$exp_32_tgz" ] || \
    (echo Wrong tgz output; exit 1)
[ -f "$exp_32_tgz" ] || (echo Failed archive fetch; exit 1)
# Refetch does not raise error
[ "$(get_gf_lib_for_suf "${SUF}" "openblas-0.2.18" "i686")" == "$exp_32_tgz" ] || \
    (echo Wrong tgz output; exit 1)
# Same thing, setting the hash manually, for OSX
GFORTRAN_SHA="1becaaa76fe86f86df35f89ca30446c14a072d41"
rm $exp_64_tgz $exp_32_tgz
[ "$(get_gf_lib "openblas-0.2.18" "x86_64")" == "$exp_64_tgz" ] || \
    (echo Wrong tgz output; exit 1)
[ -f "$exp_64_tgz" ] || (echo Failed archive fetch; exit 1)
[ "$(get_gf_lib "openblas-0.2.18" "i686")" == "$exp_32_tgz" ] || \
    (echo Wrong tgz output; exit 1)
[ -f "$exp_32_tgz" ] || (echo Failed archive fetch; exit 1)
