FROM ubuntu:20.04

# Stop ubuntu-20 interactive options.
ENV DEBIAN_FRONTEND noninteractive

# Stop script if any individual command fails.
RUN set -e

# Define LLVM version.
ENV llvm_version=16.0.0

# Define home directory
ENV HOME=/home/SVF-tools

# Define dependencies.
ENV lib_deps="g++-8 gcc-8 git zlib1g-dev libncurses5-dev libtinfo5 build-essential libssl-dev libpcre2-dev zip"
ENV build_deps="wget xz-utils git gdb tcl"

# Fetch dependencies.
RUN apt-get update
RUN apt-get install -y $build_deps $lib_deps

# Install cmake and setup PATH
ENV cmake_version="3.28.1"
ENV arch="x86_64"
RUN wget https://github.com/Kitware/CMake/releases/download/v$cmake_version/cmake-$cmake_version-linux-$arch.tar.gz -O cmake.tar.gz
RUN tar -xf cmake.tar.gz -C /home && rm -f cmake.tar.gz
ENV PATH=/home/cmake-${cmake_version}-linux-${arch}/bin:${PATH}

# Fetch and build SVF source.
RUN echo "Downloading LLVM and building SVF to " ${HOME}
WORKDIR ${HOME}
RUN git clone "https://github.com/SVF-tools/SVF.git"
WORKDIR ${HOME}/SVF
RUN echo "Building SVF ..."
RUN bash ./build.sh 

# Export SVF and llvm paths
ENV PATH=${HOME}/SVF/Release-build/bin:$PATH
ENV PATH=${HOME}/SVF/llvm-$llvm_version.obj/bin:$PATH
ENV SVF_DIR=${HOME}/SVF
ENV LLVM_DIR=${HOME}/SVF/llvm-$llvm_version.obj
ENV Z3_DIR=${HOME}/SVF/z3.obj

# Fetch and build Teaching-Software-Verification example.
WORKDIR ${HOME}
RUN git clone "https://github.com/SVF-tools/Teaching-Software-Verification.git"
WORKDIR ${HOME}/Teaching-Software-Verification
RUN echo "Building SVF-Teaching example ..."
RUN cmake -DCMAKE_BUILD_TYPE=Release .
RUN make
