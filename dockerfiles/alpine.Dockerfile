ARG BASE_IMAGE=alpine:3.23
ARG PYTHON_VERSION=system
FROM ${BASE_IMAGE}

ARG PYTHON_VERSION

COPY requirements/apk.txt /tmp/apk.txt
COPY requirements/pip.txt /tmp/pip.txt

RUN xargs -a /tmp/apk.txt apk add --no-cache

RUN if [ "$PYTHON_VERSION" != "system" ]; then \
        apk add --no-cache python${PYTHON_VERSION} python${PYTHON_VERSION}-dev 2>/dev/null && \
        ln -sf /usr/bin/python${PYTHON_VERSION} /usr/bin/python3 && \
        echo "${PYTHON_VERSION}" > /tmp/python_version || \
        (apk add --no-cache python3 python3-dev && \
         python3 -c "import sys; print('{}.{}'.format(sys.version_info.major, sys.version_info.minor))" > /tmp/python_version); \
    else \
        apk add --no-cache python3 python3-dev && \
        python3 -c "import sys; print('{}.{}'.format(sys.version_info.major, sys.version_info.minor))" > /tmp/python_version; \
    fi

RUN PYTHON_VER=$(cat /tmp/python_version) && \
    python${PYTHON_VER} -m venv /opt/venv && \
    if [ ! -f /opt/venv/bin/python ]; then \
        ln -sf /opt/venv/bin/python3 /opt/venv/bin/python; \
    fi && \
    . /opt/venv/bin/activate && \
    pip install --upgrade pip setuptools wheel && \
    pip install --no-cache-dir -r /tmp/pip.txt && \
    rm -f /tmp/python_version && \
    rm -rf /root/.cache

ENV PATH="/opt/venv/bin:$PATH"

CMD ["bash"]
