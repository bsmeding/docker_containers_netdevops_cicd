ARG BASE_IMAGE=rockylinux:9
ARG PYTHON_VERSION=system
FROM ${BASE_IMAGE}

ARG PYTHON_VERSION

COPY requirements/dnf.txt /tmp/dnf.txt
COPY requirements/pip.txt /tmp/pip.txt

RUN dnf install -y dnf-plugins-core epel-release findutils && \
    xargs -a /tmp/dnf.txt dnf install -y --allowerasing && \
    dnf clean all

RUN if [ "$PYTHON_VERSION" != "system" ]; then \
        (dnf install -y python${PYTHON_VERSION} python${PYTHON_VERSION}-pip python${PYTHON_VERSION}-devel 2>/dev/null && \
         alternatives --install /usr/bin/python3 python3 /usr/bin/python${PYTHON_VERSION} 1 && \
         alternatives --set python3 /usr/bin/python${PYTHON_VERSION} || true) || \
        (echo "Python ${PYTHON_VERSION} not available, using system Python" && \
         dnf install -y python3 python3-pip python3-devel); \
    else \
        dnf install -y python3 python3-pip python3-devel; \
    fi && \
    dnf clean all

RUN if [ "$PYTHON_VERSION" != "system" ] && command -v python${PYTHON_VERSION} >/dev/null 2>&1; then \
        python${PYTHON_VERSION} -m venv /opt/venv; \
    else \
        python3 -m venv /opt/venv; \
    fi && \
    if [ ! -f /opt/venv/bin/python ]; then \
        ln -sf /opt/venv/bin/python3 /opt/venv/bin/python; \
    fi

ENV PATH="/opt/venv/bin:$PATH"

RUN pip install --upgrade pip setuptools wheel && \
    pip install --no-cache-dir -r /tmp/pip.txt && \
    rm -rf /root/.cache

CMD ["bash"]
