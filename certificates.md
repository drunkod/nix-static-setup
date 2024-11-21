On Termux, the SSL certificates are typically located in a different path. Here's how you can find and set the correct SSL certificate path:

1. **Default Termux SSL cert location**:
```bash
SSL_CERT_FILE="$PREFIX/etc/tls/cert.pem"
```
or
```bash
SSL_CERT_FILE="/data/data/com.termux/files/usr/etc/tls/cert.pem"
```

2. **To find the exact location**, you can use these commands in Termux:
```bash
# Method 1: Find all cert.pem files
find $PREFIX -name "cert.pem"

# Method 2: Check the OpenSSL default path
openssl version -d

# Method 3: Echo the system SSL cert path
echo "$SSL_CERT_FILE"
```

3. **Modified script for Termux**:
```bash
#!/bin/bash

# Auto-detect SSL cert location
if [ -f "$PREFIX/etc/tls/cert.pem" ]; then
    SSL_CERT_FILE="$PREFIX/etc/tls/cert.pem"
elif [ -f "/data/data/com.termux/files/usr/etc/tls/cert.pem" ]; then
    SSL_CERT_FILE="/data/data/com.termux/files/usr/etc/tls/cert.pem"
else
    echo "Could not find SSL certificates"
    echo "Please install CA certificates:"
    echo "pkg install ca-certificates"
    exit 1
fi

# Rest of your script...
```

4. **If certificates are missing**, install them:
```bash
pkg update
pkg install ca-certificates
```

This should help you locate and set up the correct SSL certificate path for Termux. The modified script includes auto-detection and helpful error messages if the certificates are not found.
