FROM kalilinux/kali-rolling

# ── System update ─────────────────────────────────────────────────────────────
RUN apt-get update && apt-get upgrade -y

# ── Core Linux utilities (ensure nothing is missing from slim base) ────────────
RUN apt-get install -y \
        # Shell & text
        bash \
        zsh \
        vim \
        nano \
        less \
        man-db \
        tree \
        htop \
        # File & archive
        file \
        zip \
        unzip \
        tar \
        gzip \
        bzip2 \
        7zip \
        # Process & system
        procps \
        lsof \
        util-linux \
        psmisc \
        # Network — basic
        iputils-ping \
        iputils-tracepath \
        iproute2 \
        net-tools \
        traceroute \
        bind9-dnsutils \
        whois \
        arp-scan \
        # Data & encoding
        xxd \
        bsdmainutils \
        openssl \
        # Build tools
        gcc \
        g++ \
        make \
        perl \
        ruby \
        python3 \
        python3-pip \
        git \
        binutils \
        strace \
        ltrace \
        gdb \
    && rm -rf /var/lib/apt/lists/*

# ── Cybersecurity tools ───────────────────────────────────────────────────────
RUN apt-get update && apt-get install -y \
        # Packet analysis
        tcpdump \
        tshark \
        wireshark \
        # Scanning & enumeration
        nmap \
        gobuster \
        dirb \
        nikto \
        ffuf \
        # SMB / AD enumeration
        smbclient \
        enum4linux \
        ldap-utils \
        # Password attacks
        hydra \
        medusa \
        john \
        hashcat \
        # Exploitation
        netcat-traditional \
        socat \
        # Web & SQL
        sqlmap \
        curl \
        wget \
        # Protocols
        telnet \
        ftp \
        openssh-client \
        # Pivoting
        proxychains4 \
        # Exploit search
        exploitdb \
        # Post-exploitation
        sudo \
        # Python security libs
        python3-pwntools \
        python3-impacket \
        # Wordlists
        wordlists \
    && rm -rf /var/lib/apt/lists/* \
    && gunzip /usr/share/wordlists/rockyou.txt.gz 2>/dev/null || true

# ── MySQL client (week 5 & 7 labs) ────────────────────────────────────────────
RUN apt-get update && apt-get install -y default-mysql-client \
    && rm -rf /var/lib/apt/lists/*

# ── Verify key commands are available ─────────────────────────────────────────
RUN ping -c1 127.0.0.1 > /dev/null 2>&1 && echo "ping OK" && \
    ip addr show lo > /dev/null 2>&1    && echo "ip OK"   && \
    ifconfig lo > /dev/null 2>&1        && echo "ifconfig OK" && \
    nmap -V > /dev/null 2>&1            && echo "nmap OK"

# ── Create hacker user with sudo ──────────────────────────────────────────────
RUN useradd -m -s /bin/bash hacker && \
    echo 'hacker:hacker' | chpasswd && \
    echo 'hacker ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    usermod -aG sudo hacker

USER hacker
WORKDIR /home/hacker
CMD ["/bin/bash"]
