
   
ARG UBUNTU_VERSION=20.04
FROM ubuntu:${UBUNTU_VERSION}

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get upgrade -y

RUN apt-get install -y git build-essential cmake m4 ninja-build python3

# Latest versions as of 09/16/2020.
# llvm12
ARG LLVM_VERSION=ef32c611aa214dea855364efd7ba451ec5ec3f74
ARG LLVMGO_VERSION=2be4b2f856f80b0f2360cd26d4ab1f34a41df5b2
# go1.15rc2
ARG GOFRONTEND_VERSION=20221e9ec1722a063dbc41752ea97fd60c9e8361
ARG LIBBACKTRACK_VERSION=9b7f216e867916594d81e8b6118f092ac3fcf704
ARG LIBFFI_VERSION=v3.3

# Follow install instructions from https://go.googlesource.com/gollvm/

WORKDIR /workarea

RUN git clone https://github.com/llvm/llvm-project.git && cd llvm-project && git checkout ${LLVM_VERSION}
RUN cd llvm-project/llvm/tools && \
    git clone https://go.googlesource.com/gollvm && cd gollvm && git checkout ${LLVMGO_VERSION} && \
    git clone https://go.googlesource.com/gofrontend && cd gofrontend && git checkout ${GOFRONTEND_VERSION} && cd ../libgo && \
    git clone https://github.com/libffi/libffi.git && cd libffi && git checkout ${LIBFFI_VERSION} && cd .. && \
    git clone https://github.com/ianlancetaylor/libbacktrace.git && cd libbacktrace && git checkout ${LIBBACKTRACK_VERSION}

WORKDIR /workarea/build.rel
RUN cmake -DCMAKE_INSTALL_PREFIX=/goroot -DCMAKE_BUILD_TYPE=Release -DLLVM_USE_LINKER=gold -G Ninja ../llvm-project/llvm
RUN ninja gollvm
RUN ninja install-gollvm

ENV LD_LIBRARY_PATH=/workarea/build.rel/tools/gollvm/libgo

# Check the go version.
RUN go version
