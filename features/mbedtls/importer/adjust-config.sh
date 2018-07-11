#!/bin/sh
#
# This file is part of mbed TLS (https://tls.mbed.org)
#
# Copyright (c) 2015-2016, ARM Limited, All Rights Reserved
#
# Purpose
#
# Comments and uncomments #define lines in the given configuration header file
# to configure the file for use in mbed OS.
#
# Usage: adjust-config.sh [path to config script] [path to config file]
#
set -eu

if [ $# -ne 2 ]; then
    echo "Usage: $0 path/to/config.pl path/to/config.h" >&2
    exit 1
fi

SCRIPT=$1
FILE=$2

conf() {
    $SCRIPT -f $FILE $@
}

add_code() {
    MATCH_PATTERN="$1"
    shift
    CODE=$(IFS=""; printf "%s" "$*")

    perl -i -pe                                    \
        "s/$MATCH_PATTERN/$MATCH_PATTERN$CODE/igs" \
        "$FILE"
}

# add an #ifndef to include config-no-entropy.h when the target does not have
# an entropy source we can use.
add_code                                                                                  \
    "#ifndef MBEDTLS_CONFIG_H\n"                                                          \
    "\n"                                                                                  \
    "#include \"platform\/inc\/platform_mbed.h\"\n"                                       \
    "\n"                                                                                  \
    "\/*\n"                                                                               \
    " * Only use features that do not require an entropy source when\n"                   \
    " * DEVICE_ENTROPY_SOURCE is not defined in mbed OS.\n"                               \
    " *\/\n"                                                                              \
    "#if !defined(MBEDTLS_ENTROPY_HARDWARE_ALT) && !defined(MBEDTLS_TEST_NULL_ENTROPY)\n" \
    "#include \"mbedtls\/config-no-entropy.h\"\n"                                         \
    "\n"                                                                                  \
    "#if defined(MBEDTLS_USER_CONFIG_FILE)\n"                                             \
    "#include MBEDTLS_USER_CONFIG_FILE\n"                                                 \
    "#endif\n"                                                                            \
    "\n"                                                                                  \
    "#else\n"

add_code                                                                                \
    "#include \"check_config.h\"\n"                                                     \
    "\n"                                                                                \
    "#endif \/* !MBEDTLS_ENTROPY_HARDWARE_ALT && !MBEDTLS_TEST_NULL_ENTROPY *\/\n"      \
    "\n"                                                                                \
    "#if defined(MBEDTLS_TEST_NULL_ENTROPY)\n"                                          \
    "#warning \"MBEDTLS_TEST_NULL_ENTROPY has been enabled. This \" \\\\\n"             \
    "    \"configuration is not secure and is not suitable for production use\"\n"      \
    "#endif\n"                                                                          \
    "\n"                                                                                \
    "#if defined(MBEDTLS_SSL_TLS_C) && !defined(MBEDTLS_TEST_NULL_ENTROPY) && \\\\\n"   \
    "    !defined(MBEDTLS_ENTROPY_HARDWARE_ALT) && !defined(MBEDTLS_ENTROPY_NV_SEED)\n" \
    "#error \"No entropy source was found at build time, so TLS \" \\\\\n"              \
    "    \"functionality is not available\"\n"                                          \
    "#endif\n"

# not supported on mbed OS, nor used by mbed Client
conf unset MBEDTLS_NET_C
conf unset MBEDTLS_TIMING_C

# not supported on all targets with mbed OS, nor used by mbed Client
conf unset MBEDTLS_HAVE_TIME_DATE
conf unset MBEDTLS_FS_IO
conf set MBEDTLS_NO_PLATFORM_ENTROPY

conf unset MBEDTLS_CIPHER_MODE_CFB
conf unset MBEDTLS_CIPHER_MODE_CTR
conf unset MBEDTLS_CIPHER_PADDING_ONE_AND_ZEROS
conf unset MBEDTLS_CIPHER_PADDING_ZEROS_AND_LEN
conf unset MBEDTLS_CIPHER_PADDING_ZEROS
conf unset MBEDTLS_CIPHER_MODE_XTS
conf unset MBEDTLS_ECP_DP_SECP192R1_ENABLED
conf unset MBEDTLS_ECP_DP_SECP224R1_ENABLED
conf unset MBEDTLS_ECP_DP_SECP521R1_ENABLED
conf unset MBEDTLS_ECP_DP_SECP192K1_ENABLED
conf unset MBEDTLS_ECP_DP_SECP224K1_ENABLED
conf unset MBEDTLS_ECP_DP_SECP256K1_ENABLED
conf unset MBEDTLS_ECP_DP_BP256R1_ENABLED
conf unset MBEDTLS_ECP_DP_BP384R1_ENABLED
conf unset MBEDTLS_ECP_DP_BP512R1_ENABLED
conf unset MBEDTLS_PK_PARSE_EC_EXTENDED

conf unset MBEDTLS_AESNI_C
conf unset MBEDTLS_ARC4_C
conf unset MBEDTLS_BLOWFISH_C
conf unset MBEDTLS_CAMELLIA_C
conf unset MBEDTLS_DES_C
conf unset MBEDTLS_DHM_C
conf unset MBEDTLS_GENPRIME
conf unset MBEDTLS_MD5_C
conf unset MBEDTLS_PADLOCK_C
conf unset MBEDTLS_PEM_WRITE_C
conf unset MBEDTLS_PKCS5_C
conf unset MBEDTLS_PKCS12_C
conf unset MBEDTLS_RIPEMD160_C
conf unset MBEDTLS_SHA1_C
conf unset MBEDTLS_XTEA_C

conf set MBEDTLS_CMAC_C

conf set MBEDTLS_AES_ROM_TABLES

conf unset MBEDTLS_X509_RSASSA_PSS_SUPPORT

conf unset MBEDTLS_X509_CSR_PARSE_C
conf unset MBEDTLS_X509_CREATE_C
conf unset MBEDTLS_X509_CRT_WRITE_C
conf unset MBEDTLS_X509_CSR_WRITE_C

conf unset MBEDTLS_KEY_EXCHANGE_DHE_PSK_ENABLED
conf unset MBEDTLS_KEY_EXCHANGE_RSA_PSK_ENABLED
conf unset MBEDTLS_KEY_EXCHANGE_RSA_ENABLED
conf unset MBEDTLS_KEY_EXCHANGE_DHE_RSA_ENABLED
conf unset MBEDTLS_KEY_EXCHANGE_ECDH_ECDSA_ENABLED
conf unset MBEDTLS_KEY_EXCHANGE_ECDH_RSA_ENABLED
conf unset MBEDTLS_SSL_FALLBACK_SCSV
conf unset MBEDTLS_SSL_CBC_RECORD_SPLITTING
conf unset MBEDTLS_SSL_PROTO_TLS1
conf unset MBEDTLS_SSL_PROTO_TLS1_1
conf unset MBEDTLS_SSL_TRUNCATED_HMAC

conf unset MBEDTLS_PLATFORM_TIME_TYPE_MACRO

conf set MBEDTLS_PSA_CRYPTO_C
