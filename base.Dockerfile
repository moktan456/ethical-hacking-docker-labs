FROM kalilinux/kali-rolling

# Install common security tools for all labs
RUN apt-get update && \
    apt-get install -y \
        # Network fundamentals — ping, ip, ifconfig, traceroute
        iputils-ping \
        iproute2 \
        net-tools \
        traceroute \
        dnsutils \
        tcpdump \
        # Scanning & enumeration
        nmap \
        gobuster \
        dirb \
        nikto \
        # Password attacks
        hydra \
        medusa \
        john \
        hashcat \
        # Exploitation & post-exploitation
        netcat-traditional \
        socat \
        python3 \
        python3-pip \
        python3-pwntools \
        # Web & SQL
        sqlmap \
        curl \
        wget \
        # Protocols
        telnet \
        ftp \
        openssh-client \
        smbclient \
        ldap-utils \
        # Pivoting
        proxychains4 \
        # Wireless & packet analysis
        wireshark \
        # Misc
        git \
        vim \
        nano \
        less \
        file \
        binutils \
        wordlists \
    && rm -rf /var/lib/apt/lists/* \
    && gunzip /usr/share/wordlists/rockyou.txt.gz 2>/dev/null || true

# Create hacker user
RUN useradd -m -s /bin/bash hacker && \
    echo 'hacker:hacker' | chpasswd && \
    usermod -aG sudo hacker

USER hacker
WORKDIR /home/hacker
CMD ["/bin/bash"]
