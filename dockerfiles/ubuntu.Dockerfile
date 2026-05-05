ARG BASE_IMAGE=ubuntu:26.04
ARG PYTHON_VERSION=system
FROM ${BASE_IMAGE}

ARG DEBIAN_FRONTEND=noninteractive
ARG PYTHON_VERSION

COPY requirements/apt.txt /tmp/apt.txt
COPY requirements/pip.txt /tmp/pip.txt

RUN apt-get update && \
    xargs -a /tmp/apt.txt apt-get install -y --no-install-recommends && \
    if [ "$PYTHON_VERSION" != "system" ]; then \
        apt-get install -y --no-install-recommends software-properties-common && \
        add-apt-repository -y ppa:deadsnakes/ppa && \
        apt-get update && \
        apt-get install -y --no-install-recommends python${PYTHON_VERSION} python${PYTHON_VERSION}-venv python${PYTHON_VERSION}-dev && \
        update-alternatives --install /usr/bin/python3 python3 /usr/bin/python${PYTHON_VERSION} 1; \
    fi && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /usr/share/doc /usr/share/man

RUN if [ "$PYTHON_VERSION" != "system" ]; then \
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
