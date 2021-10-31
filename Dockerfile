
   
ARG UBUNTU_VERSION=20.04
FROM ubuntu:${UBUNTU_VERSION}

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get upgrade -y

RUN apt-get install -y git build-essential cmake m4 ninja-build python3



# Follow install instructions from https://go.googlesource.com/gollvm/

WORKDIR /workarea

RUN git clone https://github.com/llvm/llvm-project.git 
RUN cd llvm-project/llvm/tools && \
    git clone https://go.googlesource.com/gollvm  && \
    git clone https://go.googlesource.com/gofrontend  && \
    git clone https://github.com/libffi/libffi.git  && \
    git clone https://github.com/ianlancetaylor/libbacktrace.git

WORKDIR /workarea/build.rel
RUN cmake -DCMAKE_INSTALL_PREFIX=/goroot -DCMAKE_BUILD_TYPE=Release -DLLVM_USE_LINKER=gold -G Ninja ../llvm-project/llvm
RUN ninja gollvm
RUN ninja install-gollvm

ENV LD_LIBRARY_PATH=/workarea/build.rel/tools/gollvm/libgo

# Check the go version.
RUN go version
