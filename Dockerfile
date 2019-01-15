ARG IMAGE_TARGET=alpine

# first image to download qemu and make it executable
FROM alpine AS qemu
ARG QEMU=x86_64
ARG QEMU_VERSION=v2.11.0
ADD https://github.com/multiarch/qemu-user-static/releases/download/${QEMU_VERSION}/qemu-${QEMU}-static /qemu-${QEMU}-static
RUN chmod +x /qemu-${QEMU}-static

# second image to be deployed on dockerhub
FROM ${IMAGE_TARGET}
ARG QEMU=x86_64
COPY --from=qemu /qemu-${QEMU}-static /usr/bin/qemu-${QEMU}-static
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
ARG VCS_URL
ARG ARCH=amd64
ENV DEBIAN_FRONTEND noninteractive

WORKDIR /app

RUN apk add -U --no-cache python3 python3-dev gcc linux-headers musl-dev file git && \
    git clone https://github.com/adafruit/Adafruit_Python_DHT.git && \
    cd Adafruit_Python_DHT && \
    python3 setup.py install --force-pi2

COPY requirements.txt /app/requirements.txt
RUN pip3 install -r requirements.txt

COPY src /app/
RUN chmod +x /app/manager.py

ENTRYPOINT ["/app/manager.py"]

LABEL de.uniba.ub.sensiot.schema-version="1.0" \
      de.uniba.ub.sensiot.vendor="University Library Bamberg" \
      de.uniba.ub.sensiot.build-date=$BUILD_DATE \
      de.uniba.ub.sensiot.architecture=$ARCH \
      de.uniba.ub.sensiot.version=$VERSION \
      de.uniba.ub.sensiot.vcs-ref=$VCS_REF \
      de.uniba.ub.sensiot.vcs-url=$VCS_URL
