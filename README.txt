=============================================================================
 CTF TOOLS
=============================================================================

This directory contains an archive with a built copy of the CTF tools from
illumos-gate.  The binaries are relocatable, so you can install them just
about anywhere; e.g., in "/opt/ctf":

    mkdir /opt/ctf
    cd /opt/ctf
    BASEURL=https://us-east.manta.joyent.com/Joyent_Dev/public/ctftools
    curl -sSf \
           "$BASEURL/ctftools.20141030T081701Z.9543159.tar.gz" |
           gunzip | tar xvf -

These binaries are built to run on SmartOS platforms 20141030T081701Z and
later.
