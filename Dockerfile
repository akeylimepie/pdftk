ARG GRAALVM_VERSION
ARG PDFTK_VERSION

FROM ghcr.io/graalvm/graalvm-ce:${GRAALVM_VERSION:-latest} AS builder

ARG PDFTK_VERSION

RUN gu install native-image

WORKDIR /build

RUN curl https://gitlab.com/api/v4/projects/5024297/packages/generic/pdftk-java/v${PDFTK_VERSION}/pdftk-all.jar --output pdftk-all.jar \
	&& curl https://gitlab.com/pdftk-java/pdftk/-/raw/v${PDFTK_VERSION}/META-INF/native-image/reflect-config.json --output reflect-config.json \
	&& curl https://gitlab.com/pdftk-java/pdftk/-/raw/v${PDFTK_VERSION}/META-INF/native-image/resource-config.json --output resource-config.json \
	&& native-image --static -jar pdftk-all.jar \
    	-H:Name=pdftk \
    	-H:ResourceConfigurationFiles='resource-config.json' \
    	-H:ReflectionConfigurationFiles='reflect-config.json' \
    	-H:GenerateDebugInfo=0

FROM alpine:latest
COPY --from=builder /build/pdftk /usr/bin/pdftk