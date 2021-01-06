FROM python:3.9-alpine3.12

ARG PYINSTALLER_TAG
ENV PYINSTALLER_TAG ${PYINSTALLER_TAG:-"v4.1"}

# Official Python base image is needed or some applications will segfault.
# PyInstaller needs zlib-dev, gcc, libc-dev, and musl-dev
RUN apk --update --no-cache add \
    zlib-dev \
    musl-dev \
    libc-dev \
    libffi-dev \
    gcc \
    g++ \
    git \
    pwgen \
    libxslt-dev \
    jpeg-dev \
    curl \
    && pip install --upgrade pip \
    && pip install pycrypto lxml SQLAlchemy Pillow

# Build bootloader for alpine
RUN git clone --depth 1 --single-branch --branch ${PYINSTALLER_TAG} https://github.com/pyinstaller/pyinstaller.git /tmp/pyinstaller \
    && cd /tmp/pyinstaller/bootloader \
    && CFLAGS="-Wno-stringop-overflow -Wno-stringop-truncation" python ./waf configure --no-lsb all \
    && pip install .. \
    && rm -Rf /tmp/pyinstaller

# RUN curl -L https://github.com/python-pillow/Pillow/archive/3.2.0.zip -o /tmp/pillow.zip \
#     && mkdir -p /tmp/pillow \
#     && unzip /tmp/pillow.zip -d /tmp/pillow \
#     && cd /tmp/pillow/Pillow-3.2.0 \
#     && python setup.py build_ext --disable-tk --disable-tcl --disable-zlib install \
#     && rm -Rf /tmp/pillow*


VOLUME /src
WORKDIR /src

ADD ./bin /pyinstaller
RUN chmod a+x /pyinstaller/*

ENTRYPOINT ["/pyinstaller/pyinstaller.sh"]
